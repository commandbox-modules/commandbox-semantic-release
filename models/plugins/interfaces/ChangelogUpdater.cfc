interface {

    /**
     * Updates the current changelog with the new notes.
     *
     * @notes   The notes for the new release.
     * @dryRun  Flag to indicate a dry run of the release.
     * @verbose Flag to indicate printing out extra information.
     */
    public void function run(
        required string notes,
        boolean dryRun,
        boolean verbose
    );

}
