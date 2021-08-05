component implements="interfaces.CommitParser" {

    property name="fileSystemUtil" inject="FileSystem";
    property name="print"          inject="PrintBuffer";

    /**
     * Set up jGit for the current repository to enable short hashes.
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

        variables.objectReader = repository.newObjectReader();
    }

    /**
    * Converts the commit from a jGit version to a different format used by
    * the rest of the semantic release process.
    *
    * @commit  The commit to convert.
    * @dryRun  Flag to indicate a dry run of the release.
    * @verbose Flag to indicate printing out extra information.
    *
    * @return  A converted commit.
    */
    public any function run(
        required any commit,
        boolean dryRun = false,
        boolean verbose = false
    ) {
        var ccCommit = {};
        var parts = arraySlice( replace( commit.getFullMessage(), chr( 13 ), "", "all" ).split("\n{2,}"), 1 );

        /**
         * @see https://regex101.com/r/JkO3F3/2/
         */
        emojiLogRegex = "^([📦|👌|🐛|📖|🚀|🤖|‼️|⚠️]+\s\w+)(\([^)]+\))?\:\s(.+)$";
        topParts = reFindNoCase( emojiLogRegex, parts[ 1 ], 1, true );

        ccCommit[ "type" ] = topParts.pos.len() >= 2 ?
            mid( parts[ 1 ], topParts.pos[ 2 ], topParts.len[ 2 ] ) :
            "📝 OTHER";
        // Switch out the BREAKING emoji with one that renders
        ccCommit[ "type" ] = replace( ccCommit[ "type"], "‼️ BREAKING","⚠️ BREAKING" );
        ccCommit[ "scope" ] = topParts.pos.len() >= 3 && topParts.pos[3] > 0 ?
            reReplace(mid( parts[ 1 ], topParts.pos[ 3 ], topParts.len[ 3 ] ), "[()]","", "ALL") :
            "*";
        ccCommit[ "subject" ] = topParts.pos.len() >= 4 ?
            mid( parts[ 1 ], topParts.pos[ 4 ], topParts.len[ 4 ] ) :
            "";
        ccCommit[ "body" ] = topParts.pos.len() == 1 ? parts[ 1 ] : parts[ 2 ] ?: "";
        ccCommit[ "footer" ] = parts[ 3 ] ?: "";
        ccCommit[ "isBreakingChange" ] = find( "BREAKING:", commit.getFullMessage() ) > 0;
        ccCommit[ "hash" ] = commit.getId().getName();
        ccCommit[ "shortHash" ] = objectReader.abbreviate( commit.getId() ).name();

        if ( verbose ) {
            prettyPrintCommit( ccCommit );
        }

        return ccCommit;
    }

    /**
     * Print a parsed commit in a nice format to the console.
     *
     * @commit The commit to print
     */
    private function prettyPrintCommit( commit ) {
        print.line();
        print.indented().indented().indentedMagenta( "   Hash: " ).line( commit.shortHash );
        print.indented().indented().indentedMagenta( "   Type: " ).line( commit.type );
        print.indented().indented().indentedMagenta( "  Scope: " ).line( commit.scope );
        print.indented().indented().indentedMagenta( "Subject: " ).line( commit.subject );
        print.indented().indented().indentedMagenta( "   Body: " ).line( commit.body );
        print.indented().indented().indentedMagenta( " Footer: " ).line( commit.footer );
        print.line().toConsole();
    }

}