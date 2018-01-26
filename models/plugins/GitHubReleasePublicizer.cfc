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

        cfhttp( method = "POST", url = "#replace( repositoryUrl, "github.com/", "api.github.com/repos/" )#/releases", throwonerror="true" ) {
            cfhttpparam( type = "header", name = "Authorization", value = "token #systemSettings.getSystemSetting( "GH_TOKEN", "" )#" );
            cfhttpparam( type = "body", value = serializeJSON( {
                "tag_name": "#versionPrefix##nextVersion#",
                "target_commitish": targetBranch,
                "name": "#versionPrefix##nextVersion#",
                "body": notes,
                "draft": false,
                "prerelease": false
            } ) );
        }
    }

}
