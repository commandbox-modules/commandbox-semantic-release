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
        var ccCommit = parseMessage( commit.getFullMessage() );
        ccCommit[ "hash" ] = commit.getId().getName();
        ccCommit[ "shortHash" ] = objectReader.abbreviate( commit.getId() ).name();

        if ( verbose ) {
            prettyPrintCommit( ccCommit );
        }

        return ccCommit;
    }

    /** Extract conventional header, body, and breaking footer from any standard paragraph layout. */
    public struct function parseMessage( required string message ) {
        var ccCommit = {};
        var parts = listToArray( reReplace( replace( message, chr( 13 ), "", "all" ), "\n{2,}", chr( 1 ), "all" ), chr( 1 ), true );
        var header = parts[ 1 ];
        var topParts = reFindNoCase( "^(\w+)(?:\(([^)]+)\))?(!)?\:\s(.+)$", header, 1, true );

        ccCommit.type = arrayLen( topParts.pos ) >= 2 ? lCase( mid( header, topParts.pos[ 2 ], topParts.len[ 2 ] ) ) : "other";
        ccCommit.scope = arrayLen( topParts.pos ) >= 3 && topParts.len[ 3 ] > 0 ?
            mid( header, topParts.pos[ 3 ], topParts.len[ 3 ] ) : "*";
        ccCommit.subject = arrayLen( topParts.pos ) >= 5 ? mid( header, topParts.pos[ 5 ], topParts.len[ 5 ] ) : "";
        ccCommit.body = "";
        ccCommit.footer = "";
        ccCommit.isBreakingChange = arrayLen( topParts.pos ) >= 4 && topParts.len[ 4 ] > 0;

        var i = 0;
        for ( var paragraph in parts ) {
            i++;
            if ( i == 1 ) continue;
            if ( reFindNoCase( "(?m)^BREAKING(?: CHANGE|-CHANGE):\s*\S", paragraph ) ) {
                ccCommit.footer = arrayToList( arraySlice( parts, i ), chr( 10 ) & chr( 10 ) );
                ccCommit.isBreakingChange = true;
                break;
            }
            ccCommit.body &= ( len( ccCommit.body ) ? chr( 10 ) & chr( 10 ) : "" ) & paragraph;
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
