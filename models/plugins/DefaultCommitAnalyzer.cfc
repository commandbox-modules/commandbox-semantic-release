component implements="interfaces.CommitAnalyzer" {

    /**
    * Returns the release type given the array of commits.
    *
    * @commits An array of commits to analyze for the next change.
    * @dryRun  Flag to indicate a dry run of the release.
    * @verbose Flag to indicate printing out extra information.
    *
    * @return  The next release type: major, minor, or patch.
    */
    public string function run(
        required array commits,
        boolean dryRun = false,
        boolean verbose = false
    ) {
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
