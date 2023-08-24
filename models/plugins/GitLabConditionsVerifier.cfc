component implements="interfaces.ConditionsVerifier" {

    property name="systemSettings"     inject="SystemSettings";
    property name="print"              inject="PrintBuffer";

    property name="buildCommitMessage" inject="commandbox:moduleSettings:commandbox-semantic-release:buildCommitMessage";
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

        // false if not on gitlab ci
        if ( ! systemSettings.getSystemSetting( "GITLAB_CI", false ) ) {
            print.yellowLine( "Not running on GitLab CI." ).toConsole();
            return false;
        }

        // false if the commit message is our special commit message
        if ( systemSettings.getSystemSetting( "CI_COMMIT_MESSAGE", "" ) == buildCommitMessage ) {
            print.yellowLine( "Build kicked off from previous release — aborting release." ).toConsole();
            return false;
        }

        // false if a pull request
        if ( systemSettings.getSystemSetting( "CI_MERGE_REQUEST_ID", "false" ) != "false" ) {
            print.yellowLine( "Currently building a Pull Request." ).toConsole();
            return false;
        }

        // false if a tag
        if ( systemSettings.getSystemSetting( "CI_COMMIT_TAG", "false" ) != "false" ) {
            print.yellowLine( "Currently building a tag." ).toConsole();
            return false;
        }

        // false if not our configured branch (usually master)
        if ( systemSettings.getSystemSetting( "CI_COMMIT_BRANCH", "" ) != targetBranch ) {
            print.yellowLine( "Currently building against the [#systemSettings.getSystemSetting( "CI_COMMIT_BRANCH", "" )#] branch." ).toConsole();
            print.yellowLine( "Releases only happen when builds are triggered against the [#targetBranch#] branch." ).toConsole();
            return false;
        }

        // GitLab CI doesn't have a concept of a matrix of jobs
        // Instead, you are expected to define all of your jobs as
        // different yaml tasks (using includes, anchors, etc.).
        // Additionally, you can specify only one job to run
        // semantic release AFTER all of your tests, so we don't
        // need to check other jobs here.
        return true;
    }

}
