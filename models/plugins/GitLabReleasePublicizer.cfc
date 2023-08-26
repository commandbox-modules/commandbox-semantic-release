component implements="interfaces.ReleasePublicizer" {

    property name="versionPrefix"  inject="commandbox:moduleSettings:commandbox-semantic-release:versionPrefix";
    property name="targetBranch"   inject="commandbox:moduleSettings:commandbox-semantic-release:targetBranch";
    property name="systemSettings" inject="SystemSettings";

    /**
     * Publishes the release notes to GitHub.
     *
     * @notes         The release notes to publish.
     * @nextVersion   The next version of the package.
     * @repositoryUrl The url of the remote repository.
     * @dryRun        Flag to indicate a dry run of the release.
     * @verbose       Flag to indicate printing out extra information.
     * @targetBranch     The branch that builds are triggered against.
     */
    public void function run(
        required string notes,
        required string nextVersion,
        required string repositoryUrl,
        boolean dryRun = false,
        boolean verbose = false,
        string targetBranch = variables.targetBranch
    ) {
        if ( dryRun ) {
            return;
        }

        cfhttp(
            method = "POST",
            url = "#systemSettings.getSystemSetting( "CI_API_V4_URL" )#/projects/#systemSettings.getSystemSetting( "CI_PROJECT_ID", "" )#/releases",
            throwonerror="true"
        ) {
            cfhttpparam(
                type="header",
                name="Content-Type",
                value="application/json"
            );
            cfhttpparam(
                type="header",
                name="JOB-TOKEN",
                value="#systemSettings.getSystemSetting( "GITLAB_ACCESS_TOKEN" )#"
            );
            cfhttpparam( type = "body", value = serializeJSON( {
                "name": "#versionPrefix##nextVersion#",
                "tag_name": "#versionPrefix##nextVersion#",
                "ref": arguments.targetBranch,
                "description": notes
            } ) );
        }
    }

}
