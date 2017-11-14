interface {

    public string function run(
        required string lastVersion,
        required string nextVersion,
        required array commits,
        required string type,
        required string repositoryUrl
    );

}
