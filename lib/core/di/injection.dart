import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/home/di/home_di.dart';
import '../../features/sorting/di/sorting_di.dart';
import '../../features/searching/di/searching_di.dart';
import '../../features/graph/di/graph_di.dart';
import '../../features/data_structures/di/ds_di.dart';
import '../../features/recursion/di/recursion_di.dart';
import '../../features/dynamic_programming/di/dp_di.dart';
import '../../features/settings/di/settings_di.dart';
import '../helper/cache_helper.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupGetIt() async {
  // Core Services
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  getIt.registerSingleton<CacheHelper>(CacheHelper(sharedPreferences));

  // Feature DI
  HomeDI().init();
  SortingDI().init();
  SearchingDI().init();
  GraphDI().init();
  DSDI().init();
  RecursionDI().init();
  DPDI().init();
  SettingsDI().init();
}

Future<void> resetGetIt() async {
  await getIt.reset();
  await setupGetIt();
}
