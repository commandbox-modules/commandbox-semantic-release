component implements="interfaces.ConditionsVerifier" {

    property name="systemSettings"     inject="SystemSettings";
    property name="print"              inject="PrintBuffer";

    property name="buildCommitMessage" inject="commandbox:moduleSettings:commandbox-semantic-release:buildCommitMessage";
    property name="options"            inject="commandbox:moduleSettings:commandbox-semantic-release:pluginOptions";
    property name="targetBranch"       inject="commandbox:moduleSettings:commandbox-semantic-release:targetBranch";

    /**
    * Verifies the conditions are right to run the release.
    *
    * @dryRun  Flag to indicate a dry run of the release.
    * @verbose Flag to indicate printing out extra information.
    *
    * @returns True if the release should run.
    */
    public boolean function run( boolean dryRun = false, boolean verbose = false ) {
        // false if build skip commit message
        if ( findNoCase( systemSettings.getSystemSetting( "BUILD_SKIP_COMMIT_MESSAGE", "[skip release]" ), systemSettings.getSystemSetting( "TRAVIS_COMMIT_MESSAGE", "" ) ) > 0 ) {
            print.yellowLine( "Commit requests the build to be skipped — aborting release." ).toConsole();
            return false;
        }

        if ( dryRun ) {
            return true;
        }

        // false if not on travis
        if ( ! systemSettings.getSystemSetting( "TRAVIS", false ) ) {
            print.yellowLine( "Not running on Travis CI." ).toConsole();
            return false;
        }

        // false
        if ( systemSettings.getSystemSetting( "TRAVIS_COMMIT_MESSAGE", "" ) == buildCommitMessage ) {
            print.yellowLine( "Build kicked off from previous release — aborting release." ).toConsole();
            return false;
        }

        // false if a pull request
        if ( systemSettings.getSystemSetting( "TRAVIS_PULL_REQUEST", "false" ) != "false" ) {
            print.yellowLine( "Currently building a Pull Request." ).toConsole();
            return false;
        }

        // false if a tag
        if ( systemSettings.getSystemSetting( "TRAVIS_TAG", "" ) != "" ) {
            print.yellowLine( "Currently building a tag." ).toConsole();
            return false;
        }

        // false if not our configured branch (usually master)
        if ( systemSettings.getSystemSetting( "TRAVIS_BRANCH", "" ) != targetBranch ) {
            print.yellowLine( "Currently building against the [#systemSettings.getSystemSetting( "TRAVIS_BRANCH", "" )#] branch." ).toConsole();
            print.yellowLine( "Releases only happen when builds are triggered against the [#targetBranch#] branch." ).toConsole();
            return false;
        }

        var jobs = getTravisJobs( systemSettings.getSystemSetting( "TRAVIS_BUILD_ID", 0 ) );

        // true if only one job
        if ( arrayLen( jobs ) <= 1 ) {
            return true;
        }

        // false if not the build leader ( job 1 )
        if ( listLast( systemSettings.getSystemSetting( "TRAVIS_JOB_NUMBER", 0 ), "." ) != 1 ) {
            print.yellowLine( "This job is not the job leader for the build." ).toConsole();
            return false;
        }

        // false if not all jobs passed
        var startTick = getTickCount();
        var firstPass = true;
        while ( true ) {
            try {
                var pendingJobIds = jobs
                    .filter( function( job ) {
                        return job.number != systemSettings.getSystemSetting( "TRAVIS_JOB_NUMBER", 0 );
                    } )
                    .reduce( function( pendingJobs, job ) {
                        param job.allow_failure = false;
                        if ( ! job.allow_failure && job.state != "passed" ) {
                            if ( job.state == "errored" || job.state == "failed" ) {
                                if( verbose ) {
                                    print.line( "Job ###job.number# #job.state#." );
                                }
                                throw(
                                    type = "FailedTravisJob",
                                    message = "Job failed. Abort release."
                                );
                            }
                            pendingJobs.append( job.number );
                        }
                        return pendingJobs;
                    }, [] );
            }
            catch ( FailedTravisJob e ) {
                // false if we run in to an error
                print.yellowLine( "One or more of the jobs was not successful." ).toConsole();
                return false;
            }

            if ( pendingJobIds.len() == 0 ) {
                return true;
            }

            var elapsedTimeInSeconds = ( getTickCount() - startTick ) / 1000;
            if ( elapsedTimeInSeconds > options.VerifyConditions.buildTimeout ) {
                print.line( "" )
                    .yellowLine( "Timed out waiting for other jobs to finish." )
                    .toConsole();
                return false;
            }

            if ( firstPass ) {
                firstPass = false;
                print.white( "Polling..." ).toConsole();
            }

            sleep( options.VerifyConditions.pollingInterval );
            print.white( "." ).toConsole();

            // refresh the jobs from the API
            jobs = getTravisJobs( systemSettings.getSystemSetting( "TRAVIS_BUILD_ID", 0 ) );
        }

        // shouldn't be able to get here ¯\_(ツ)_/¯
        return false;
    }

    private function getTravisJobs( buildId ) {
        var httpResponse = "";
        cfhttp( url="https://api.travis-ci.org/build/#buildId#/jobs", result="httpResponse", throwonerror="true" ) {
            cfhttpparam( type="header", name="Travis-API-Version", value="3" );
            // TODO: where are we getting this token from?
            cfhttpparam( type="header", name="Authorization", value="token #systemSettings.getSystemSetting( "TRAVIS_TOKEN", "" )#" );
        };
        return deserializeJSON( httpResponse.filecontent ).jobs;
    }

}
