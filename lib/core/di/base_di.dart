abstract class BaseDI {
  void registerDataSources();
  void registerRepositories();
  void registerUseCases();
  void registerBlocs();

  void init() {
    registerDataSources();
    registerRepositories();
    registerUseCases();
    registerBlocs();
  }
}
