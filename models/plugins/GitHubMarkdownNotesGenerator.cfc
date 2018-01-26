component implements="interfaces.NotesGenerator" {

    property name="print" inject="PrintBuffer";

    /**
     * Generates markdown notes for the new release on GitHub
     *
     * @lastVersion   The last version of the package.
     * @nextVersion   The next version of the package.
     * @commits       An array of commits between the two versions.
     * @type          The type of the next release: major, minor, or patch.
     * @repositoryUrl The url of the remote repository.
     * @dryRun        Flag to indicate a dry run of the release.
     * @verbose       Flag to indicate printing out extra information.
     *
     * @return        A string containing the new notes for the release.
     */
    public string function run(
        required string lastVersion,
        required string nextVersion,
        required array commits,
        required string type,
        required string repositoryUrl,
        boolean dryRun = false,
        boolean verbose = true
    ) {
        var docCommits = commits.reduce( function( docs, commit ) {
            if ( commit.isBreakingChange ) {
                if ( ! docs.keyExists( "breaking" ) ) {
                    docs.breaking = [];
                }
                docs.breaking.append( commit );
                return docs;
            }

            if ( ! docs.keyExists( commit.type ) ) {
                docs[ commit.type ] = [];
            }
            docs[ commit.type ].append( commit );
            return docs;
        }, {} );
        var docsArray = [];
        var headers = structKeyArray( docCommits );
        arraySort( headers, "textnocase" );
        for ( var header in headers ) {
            docsArray.append( "###### #header#" );
            docsArray.append( "" );
            arrayAppend( docsArray, docCommits[ header ].map( function( commit ) {
                var subject = commit.subject != "" ? commit.subject : commit.body;
                var scope = commit.scope == "*" ? "\*" : commit.scope;
                return "+ __#scope#:__ #subject# ([#commit.shortHash#](#repositoryUrl#/commit/#commit.hash#))";
            } ), true );
            docsArray.append( "" );
        }
        var generatedDocs = arrayToList( docsArray, "#chr(10)#" );
        if ( verbose ) {
            print.line()
                .indented()
                .boldBlackOnYellowLine( "      NEW NOTES      " )
                .line()
                .whiteLine( generatedDocs )
                .line()
                .indented()
                .boldBlackOnYellowLine( "      END NOTES      " )
                .line()
                .toConsole();
        }
        return generatedDocs;
    }

}
