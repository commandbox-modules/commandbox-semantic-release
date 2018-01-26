interface {

    /**
    * Retieves the commits for since the last release.
    *
    * @since   The reference to the last release, usually a tag.
    * @dryRun  Flag to indicate a dry run of the release.
    * @verbose Flag to indicate printing out extra information.
    *
    * @return  An array of commits to analyze.
    */
    public array function run( required string since, boolean dryRun, boolean verbose );

}
