component extends="testbox.system.BaseSpec" {
    function run() {
        describe( "breaking release classification", function() {
            beforeEach( function() {
                variables.parser = new semanticRelease.models.plugins.ConventionalChangelogParser();
                variables.analyzer = new semanticRelease.models.plugins.DefaultCommitAnalyzer();
            } );

            it( "recognizes qb's breaking commits with a footer directly after the subject", function() {
                var messages = [
                    "feat(QueryBuilder): match null upsert targets (issue 324)" & chr( 10 ) & chr( 10 ) &
                        "BREAKING CHANGE: Custom grammars overriding compileUpsert must accept matchNulls.",
                    "feat(QueryBuilder): add named return formatters (issue 315)" & chr( 10 ) & chr( 10 ) &
                        "BREAKING CHANGE: Native queryExecute returntype options are no longer honored."
                ];
                var commits = messages.map( function( message ) { return parser.parseMessage( message ); } );
                expect( commits[ 1 ].scope ).toBe( "QueryBuilder" );
                expect( commits[ 1 ].subject ).toBe( "match null upsert targets (issue 324)" );
                expect( commits[ 1 ].footer ).toInclude( "BREAKING CHANGE:" );
                expect( analyzer.run( commits ) ).toBe( "major" );
            } );

            it( "finds a footer after multiple body paragraphs", function() {
                var commit = parser.parseMessage( "fix(qb): change behavior" & chr( 10 ) & chr( 10 ) &
                    "First explanation." & chr( 10 ) & chr( 10 ) & "Second explanation." & chr( 10 ) & chr( 10 ) &
                    "BREAKING CHANGE: Consumers must adapt." );
                expect( commit.body ).toInclude( "Second explanation." );
                expect( commit.footer ).toInclude( "Consumers must adapt." );
                expect( analyzer.run( [ commit ] ) ).toBe( "major" );
            } );

            it( "recognizes conventional exclamation headers but ignores a body mention", function() {
                expect( analyzer.run( [ parser.parseMessage( "fix!: change behavior" ) ] ) ).toBe( "major" );
                expect( analyzer.run( [ parser.parseMessage( "feat(qb)!: change behavior" ) ] ) ).toBe( "major" );
                var commit = parser.parseMessage( "fix(qb): ordinary fix" & chr( 10 ) & chr( 10 ) &
                    "The docs mention BREAKING CHANGE: as an example." );
                expect( commit.isBreakingChange ).toBeFalse();
                expect( analyzer.run( [ commit ] ) ).toBe( "patch" );
            } );
        } );
    }
}
