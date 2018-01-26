interface {

    /**
    * Returns the latest version of the package slug.
    *
    * @slug    The slug of the package to find the latest version.
    * @dryRun  Flag to indicate a dry run of the release.
    * @verbose Flag to indicate printing out extra information.
    *
    * @return  The latest version of the package.
    */
    public string function run( required string slug, boolean dryRun, boolean verbose );

}
