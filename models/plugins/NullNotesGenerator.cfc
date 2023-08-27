component implements="interfaces.NotesGenerator" {

    /**
     * Generates markdown notes for the new release on GitHub
     *
     * @lastVersion   The last version of the package.
     * @nextVersion   The next version of the package.
     * @commits       An array of commits between the two versions.
     * @type          The type of the next release: major, minor, or patch.
     * @repositoryUrl The url of the remote repository.
     * @dryRun        Flag to indicate a dry run of the release.
     * @verbose       Flag to indicate printing out extra information.
     *
     * @return        A string containing the new notes for the release.
     */
    public string function run(
        required string lastVersion,
        required string nextVersion,
        required array commits,
        required string type,
        required string repositoryUrl,
        boolean dryRun = false,
        boolean verbose = true
    ) {
        return "";
    }

}
