component implements="interfaces.ConditionsVerifier" {

    property name="options"        inject="commandbox:moduleSettings:commandbox-semantic-release:pluginOptions";
    property name="targetBranch"   inject="commandbox:moduleSettings:commandbox-semantic-release:targetBranch";
    property name="print"          inject="PrintBuffer";
    property name="consoleLogger"  inject="logbox:logger:console";
    property name="systemSettings" inject="SystemSettings";

    public boolean function run() {
        // false if not on travis
        if ( ! systemSettings.getSystemSetting( "TRAVIS", false ) ) {
            consoleLogger.warn( "Not running on Travis CI." );
            return false;
        }

        // false if a pull request
        if ( systemSettings.getSystemSetting( "TRAVIS_PULL_REQUEST", "false" ) != "false" ) {
            consoleLogger.warn( "Currently building a Pull Request." );
            return false;
        }

        // false if a tag
        if ( systemSettings.getSystemSetting( "TRAVIS_TAG", "" ) != "" ) {
            consoleLogger.warn( "Currently building a tag." );
            return false;
        }

        // false if not our configured branch (usually master)
        if ( systemSettings.getSystemSetting( "TRAVIS_BRANCH", "" ) != targetBranch ) {
            consoleLogger.warn( "Currently building against the [#systemSettings.getSystemSetting( "TRAVIS_BRANCH", "" )#] branch." );
            consoleLogger.warn( "Releases only happen when builds are triggered against the [#targetBranch#] branch." );
            return false;
        }

        var jobs = getTravisJobs( systemSettings.getSystemSetting( "TRAVIS_BUILD_ID", 0 ) );

        // true if only one job
        if ( arrayLen( jobs ) <= 1 ) {
            return true;
        }

        // false if not the build leader ( job 1 )
        if ( listLast( systemSettings.getSystemSetting( "TRAVIS_JOB_NUMBER", 0 ), "." ) != 1 ) {
            consoleLogger.warn( "This job is not the job leader for the build." );
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
                        if ( ! job.allow_failure && job.state != "passed" ) {
                            if ( job.state == "errored" || job.state == "failed" ) {
                                throw( "Job failed. Abort release." );
                            }
                            pendingJobs.append( job.number );
                        }
                        return pendingJobs;
                    }, [] );
            }
            catch ( any e ) {
                // false if we run in to an error
                consoleLogger.warn( "One or more of the jobs was not successful." );
                return false;
            }

            if ( pendingJobIds.len() == 0 ) {
                return true;
            }

            var elapsedTimeInSeconds = ( getTickCount() - startTick ) / 1000;
            if ( elapsedTimeInSeconds > options.VerifyConditions.buildTimeout ) {
                print.line( "" ).toConsole();
                consoleLogger.warn( "Release timed out waiting for other jobs to finish." );
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
