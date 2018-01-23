component implements="interfaces.NotesGenerator" {

    property name="parser" inject="ConventionalChangelogParser@commandbox-semantic-release";

    public string function run(
        required string lastVersion,
        required string nextVersion,
        required array commits,
        required string type,
        required string repositoryUrl
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
        return arrayToList( docsArray, "#chr(10)#" );
    }

}
