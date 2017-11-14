component implements="interfaces.ReleaseVerifier" {

    public boolean function run(
        required string lastVersion,
        required string nextVersion,
        required array commits,
        required string type
    ) {
        return true;
    }

}
