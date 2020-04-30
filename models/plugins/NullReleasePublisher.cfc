component implements="interfaces.ReleasePublisher" {

    /**
     * Publishes the new release on ForgeBox.
     *
     * @nextVersion The next version number to publish.
     * @dryRun  Flag to indicate a dry run of the release.
     * @verbose Flag to indicate printing out extra information.
     */
    public void function run(
        required string nextVersion,
        boolean dryRun = false,
        boolean verbose = false
    ) {
        return;
    }

}
