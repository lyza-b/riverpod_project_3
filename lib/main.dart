
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      // darkTheme: ThemeData.dark(),
      // themeMode: ThemeMode.dark,
      home: const HomePage(),
    );
  }
}

enum City {
  stockholm,
  paris,
  tokyo,
  nigeria,
}

typedef WeatherEmoji = String;

Future<WeatherEmoji> getWeather(City city) {
  return Future.delayed(
    const Duration(seconds: 2),
    () => {
      City.stockholm: '🌧',
      City.paris: '❄',
      City.tokyo: '🍃',
      City.nigeria: '☀',
    }[city]!,
  );
}

// UI writes to this
final currentCityProvider = StateProvider<City?>(
  (ref) => null,
);

const unknownWeatherEmoji = '🤷‍♀';

// UI reads to and reads this
final weatherProvider = FutureProvider((ref) {
  final city = ref.watch(currentCityProvider);
  if (city != null) {
    return getWeather(city);
  } else {
    return unknownWeatherEmoji;
  }
});

class HomePage extends ConsumerWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //  final display = ref.watch(weatherProvider);
    final currentWeather = ref.watch(weatherProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Weather'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          currentWeather.when(
            loading:() => const Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ) ,
            error: (_, __) =>
              const Text("Error"),
            data: (data) => Text(
              data.toString(),
              style: const TextStyle(
                fontSize: 40,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: City.values.length,
              itemBuilder: (context, index) {
                final city = City.values[index];
                final isSelected = city == ref.watch(currentCityProvider);
                return ListTile(
                  title: Text(
                    city.toString(),
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  trailing: isSelected ? const Icon(Icons.check) : null,
                  onTap: () {
                    ref.read(currentCityProvider.notifier).state = city;
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
