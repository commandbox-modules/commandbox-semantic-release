component implements="interfaces.CommitsRetriever" {

    property name="fileSystemUtil"     inject="FileSystem";
    property name="print"              inject="PrintBuffer";

    property name="versionPrefix"      inject="commandbox:moduleSettings:commandbox-semantic-release:versionPrefix";

    /**
     * Set up jGit for the current repository.
     */
    function onDIComplete() {
        var builder = createObject( "java", "org.eclipse.jgit.storage.file.FileRepositoryBuilder" ).init();
        var gitDir = createObject( "java", "java.io.File" ).init( fileSystemUtil.resolvePath( "" ) & ".git" );
        variables.repository = builder
            .setGitDir( gitDir )
            .setMustExist( true )
            .readEnvironment() // scan environment GIT_* variables
            .findGitDir() // scan up the file system tree
            .build();
    }

    /**
    * Retieves the commits for since the last release.
    *
    * @since   The reference to the last release, usually a tag.
    * @dryRun  Flag to indicate a dry run of the release.
    * @verbose Flag to indicate printing out extra information.
    *
    * @return  An array of commits to analyze.
    */
    public array function run(
        required string since,
        boolean dryRun = false,
        boolean verbose = false
    ) {
        if ( verbose ) {
            print.line()
                .indented()
                .boldBlackOnYellowLine( "  Printing out commits  " )
                .line()
                .toConsole();
        }

        var tagRef = repository.exactRef( "refs/tags/#versionPrefix##since#" );
        var walk = createObject( "java", "org.eclipse.jgit.revwalk.RevWalk" ).init( repository );
        var head = repository.exactRef( "HEAD" );
        walk.markStart( walk.parseCommit( head.getObjectId() ) );
        var commitsArray = [];
        var commitsIterator = walk.iterator();
        if ( isNull( tagRef ) ) {
            while( commitsIterator.hasNext() ) {
                var commit = commitsIterator.next();
                arrayAppend( commitsArray, commit );
            }
        }
        else {
            var targetId = repository.peel( tagRef ).getPeeledObjectId();
            if ( isNull( targetId ) ) {
                targetId = tagRef.getObjectId();
            }
            while( commitsIterator.hasNext() ) {
                var commit = commitsIterator.next();
                if ( commit.getId().equals( targetId ) ) {
                    break;
                }
                arrayAppend( commitsArray, commit );
            }
        }

        return commitsArray;
    }

}
