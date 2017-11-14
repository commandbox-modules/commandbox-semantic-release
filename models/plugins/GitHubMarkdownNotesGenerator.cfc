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
            var parsedCommit = parser.parse( commit );

            if ( parsedCommit.isBreakingChange ) {
                if ( ! docs.keyExists( "breaking" ) ) {
                    docs.breaking = [];
                }
                docs.breaking.append( parsedCommit );
                return docs;
            }

            if ( ! docs.keyExists( parsedCommit.type ) ) {
                docs[ parsedCommit.type ] = [];
            }
            docs[ parsedCommit.type ].append( parsedCommit );
            return docs;
        }, {} );
        var docsArray = [];
        var headers = structKeyArray( docCommits );
        arraySort( headers, "textnocase" );
        for ( var header in headers ) {
            docsArray.append( "###### #header#" );
            docsArray.append( "" );
            arrayAppend( docsArray, docCommits[ header ].map( function( parsedCommit ) {
                var subject = parsedCommit.subject != "" ? parsedCommit.subject : parsedCommit.body;
                var scope = parsedCommit.scope == "*" ? "\*" : parsedCommit.scope;
                return "+ __#scope#:__ #subject# ([#parsedCommit.shortHash#](#repositoryUrl#/#parsedCommit.hash#))";
            } ), true );
            docsArray.append( "" );
        }
        return arrayToList( docsArray, "#chr(10)#" );
    }

}
