interface {

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
    public any function run( required any commit, boolean dryRun, boolean verbose );

}
