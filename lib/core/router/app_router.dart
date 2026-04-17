import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/screen/main_screen.dart';
import '../../features/home/presentation/screen/home_tab.dart';
import '../../features/group/presentation/screen/group_tab.dart';
import '../../features/territories/presentation/screen/territories_tab.dart';
import '../../features/preaching_days/presentation/screen/nueva_salida_screen.dart';
import '../../features/preaching_days/presentation/screen/history_screen.dart';
import '../../features/reports/presentation/screen/reports_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainScreen(child: child),
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomeTab(),
        ),
        GoRoute(
          path: '/group',
          name: 'group',
          builder: (context, state) => const GroupTab(),
        ),
        GoRoute(
          path: '/territories',
          name: 'territories',
          builder: (context, state) => const TerritoriesTab(),
        ),
        GoRoute(
          path: '/historial',
          name: 'historial',
          builder: (context, state) => const HistoryScreen(),
        ),
        GoRoute(
          path: '/informes',
          name: 'informes',
          builder: (context, state) => const ReportsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/nueva-salida',
      name: 'nueva-salida',
      builder: (context, state) => const NuevaSalidaScreen(),
    ),
  ],
);
