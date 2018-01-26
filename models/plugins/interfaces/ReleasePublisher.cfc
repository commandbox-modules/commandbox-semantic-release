interface {

    /**
     * Publishes the new release.
     *
     * @nextVersion The next version number to publish.
     * @dryRun  Flag to indicate a dry run of the release.
     * @verbose Flag to indicate printing out extra information.
     */
    public void function run(
        required string nextVersion,
        boolean dryRun,
        boolean verbose
    );

}
