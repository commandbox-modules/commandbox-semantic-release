component implements="interfaces.CommitAnalyzer" {

    property name="parser" inject="ConventionalChangelogParser@commandbox-semantic-release";

    public string function run( required array commits, boolean dryRun = false ) {
        return commits.reduce( function( maxType, commit ) {
            if ( maxType == "major" ) {
                return "major";
            }

            if ( commit.isBreakingChange ) {
                return "major";
            }

            if ( maxType == "minor" ) {
                return "minor";
            }

            if ( commit.type == "feat" ) {
                return "minor";
            }

            return "patch";
        }, "patch" );
    }

}
