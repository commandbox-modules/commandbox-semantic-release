interface {

    /**
     * Publishes the release notes.
     *
     * @notes         The release notes to publish.
     * @nextVersion   The next version of the package.
     * @repositoryUrl The url of the remote repository.
     * @dryRun        Flag to indicate a dry run of the release.
     * @verbose       Flag to indicate printing out extra information.
     */
    public void function run(
        required string notes,
        required string nextVersion,
        required string repositoryUrl,
        boolean dryRun,
        boolean verbose
    );

}
