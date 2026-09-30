import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/dashboard_shell.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/services/presentation/my_services_screen.dart';
import '../../features/roster/presentation/shift_roster_screen.dart';
import '../../features/earnings/presentation/earnings_screen.dart';
import '../../features/claims/presentation/claims_screen.dart';
import '../../features/tasks/presentation/task_checklist_screen.dart';
import '../../features/incident/presentation/incident_report_screen.dart';
import '../../features/kudos/presentation/kudos_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardShell(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/my-services',
      builder: (context, state) => const MyServicesScreen(),
    ),
    GoRoute(
      path: '/shift-roster',
      builder: (context, state) => const ShiftRosterScreen(),
    ),
    GoRoute(
      path: '/earnings',
      builder: (context, state) => const EarningsScreen(),
    ),
    GoRoute(
      path: '/claims',
      builder: (context, state) => const ClaimsScreen(),
    ),
    GoRoute(
      path: '/task-checklist',
      builder: (context, state) => const TaskChecklistScreen(),
    ),
    GoRoute(
      path: '/incident-report',
      builder: (context, state) => const IncidentReportScreen(),
    ),
    GoRoute(
      path: '/kudos',
      builder: (context, state) => const KudosScreen(),
    ),
  ],
);
