interface {

    /**
     * Verifies that the release is able to be published.
     *
     * @lastVersion The last version of the package
     * @nextVersion The next version of the package
     * @commits     An array of commits between the two versions
     * @type        The type of change for the next release
     * @dryRun  Flag to indicate a dry run of the release.
     * @verbose Flag to indicate printing out extra information.
     *
     * @return True if the release is able to be published.
     */
    public boolean function run(
        required string lastVersion,
        required string nextVersion,
        required array commits,
        required string type,
        boolean dryRun,
        boolean verbose
    );

}
