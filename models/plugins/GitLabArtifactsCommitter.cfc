component implements="interfaces.ArtifactsCommitter" {

    property name="systemSettings"     inject="SystemSettings";
    property name="fileSystemUtil"     inject="FileSystem";

    property name="buildCommitMessage" inject="commandbox:moduleSettings:commandbox-semantic-release:buildCommitMessage";
    property name="changelogFileName"  inject="commandbox:moduleSettings:commandbox-semantic-release:changelogFileName";
    property name="versionPrefix"      inject="commandbox:moduleSettings:commandbox-semantic-release:versionPrefix";
    property name="targetBranch"       inject="commandbox:moduleSettings:commandbox-semantic-release:targetBranch";

    /**
     * Set up jGit for the current repository.
     */
    function onDIComplete() {
        var builder = createObject( "java", "org.eclipse.jgit.storage.file.FileRepositoryBuilder" ).init();
        var gitDir = createObject( "java", "java.io.File" ).init( fileSystemUtil.resolvePath( "" ) & ".git" );
        var repository = builder
            .setGitDir( gitDir )
            .setMustExist( true )
            .readEnvironment() // scan environment GIT_* variables
            .findGitDir() // scan up the file system tree
            .build();
        variables.jGit = createObject( "java", "org.eclipse.jgit.api.Git" ).init( repository );
    }

    /**
     * Gives a chance to commit any changes or artifacts produced by the build.
     *
     * @nextVersion The next version to be published.
     * @dryRun  Flag to indicate a dry run of the release.
     * @verbose Flag to indicate printing out extra information.
     * @targetBranch     The branch that builds are triggered against.
     */
    public void function run(
        required string nextVersion,
        boolean dryRun = false,
        boolean verbose = false,
        string targetBranch = variables.targetBranch
    ) {
        if ( dryRun ) {
            return;
        }

        jGit.checkout()
            .setName( targetBranch )
            .call();

        jGit.add()
            .addFilePattern( "box.json" )
            .addFilePattern( changelogFileName )
            .call();

        var commit = jGit.commit()
            .setMessage( buildCommitMessage )
            .setAuthor(
                systemSettings.getSystemSetting( "GITLAB_USER_NAME" ),
                systemSettings.getSystemSetting( "GITLAB_USER_EMAIL" )
            )
            .call();

        jGit.tag()
            .setMessage( "#versionPrefix##nextVersion#" )
            .setName( "#versionPrefix##nextVersion#" )
            .call();

        var credentials = createObject( "java", "org.eclipse.jgit.transport.UsernamePasswordCredentialsProvider" )
            .init( "PRIVATE-TOKEN", systemSettings.getSystemSetting( "GITLAB_ACCESS_TOKEN" ) );

        jGit.push()
            .setCredentialsProvider( credentials )
            .call();

        jGit.push()
            .setCredentialsProvider( credentials )
            .setPushTags()
            .call();
    }

}
