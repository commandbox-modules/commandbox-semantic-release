component implements="interfaces.CommitAnalyzer" {

    property name="parser" inject="ConventionalChangelogParser@commandbox-semantic-release";

    public string function run( required array commits ) {
        return commits.reduce( function( maxType, commit ) {
            if ( maxType == "major" ) {
                return "major";
            }

            var ccCommit = parser.parse( commit );

            if ( ccCommit.isBreakingChange ) {
                return "major";
            }

            if ( maxType == "minor" ) {
                return "minor";
            }

            if ( ccCommit.type == "feat" ) {
                return "minor";
            }

            return "patch";
        }, "patch" );
    }

}
