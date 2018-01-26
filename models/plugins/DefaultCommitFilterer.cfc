component implements="interfaces.CommitFilterer" {

    property name="buildCommitMessage" inject="commandbox:moduleSettings:commandbox-semantic-release:buildCommitMessage";

    /**
    * Filters the collection of commits.  Useful for ignoring build-only commits.
    *
    * @commits The collection of commits to filter.
    * @dryRun  Flag to indicate a dry run of the release.
    * @verbose Flag to indicate printing out extra information.
    *
    * @return  A converted commit.
    */
    public array function run( required array commits, boolean dryRun, boolean verbose ) {
        return commits.filter( function( commit ) {
            return ! commit.body.contains( buildCommitMessage );
        } );
    }

}
