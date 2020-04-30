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
     */
    public void function run(
        required string notes,
        required string nextVersion,
        required string repositoryUrl,
        boolean dryRun = false,
        boolean verbose = false
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
                name="PRIVATE-TOKEN",
                value="#systemSettings.getSystemSetting( "CI_JOB_TOKEN" )#"
            );
            cfhttpparam( type = "body", value = serializeJSON( {
                "name": "#versionPrefix##nextVersion#",
                "tag_name": "#versionPrefix##nextVersion#",
                "ref": targetBranch,
                "description": notes
            } ) );
        }
    }

}
