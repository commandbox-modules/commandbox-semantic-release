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
        if ( dryRun ) {
            return true;
        }

        // false if not on GitHub Actions
        if ( !systemSettings.getSystemSetting( "GITHUB_ACTION", false ) ) {
            print.yellowLine( "Not running on GitHub Actions." ).toConsole();
            return false;
        }

        // false if special commit message
        if ( systemSettings.getSystemSetting( "GA_COMMIT_MESSAGE", "" ) == buildCommitMessage ) {
            print.yellowLine( "Build kicked off from previous release — aborting release." ).toConsole();
            return false;
        }

        return true;
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
