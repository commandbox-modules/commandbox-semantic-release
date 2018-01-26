interface {

    /**
    * Returns the release type given the array of commits.
    *
    * @commits An array of commits to analyze for the next change.
    * @dryRun  Flag to indicate a dry run of the release.
    * @verbose Flag to indicate printing out extra information.
    *
    * @return  The next release type: major, minor, or patch.
    */
    public string function run( required array commits, boolean dryRun, boolean verbose );

}
