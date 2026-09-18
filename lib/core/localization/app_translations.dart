import 'package:flutter/material.dart';
import '../state/app_settings.dart';

/// Lightweight dictionary-based translation engine for Ngam Teams.
/// Supports English ('en') and Bahasa Melayu ('ms').
class AppTranslations {
  static const Map<String, Map<String, String>> _strings = {
    'en': {
      // Navigation
      'nav.home': 'Home',
      'nav.notices': 'Notices',
      'nav.attend': 'Attend',
      'nav.leave': 'Leave',
      'nav.settings': 'Settings',
      'nav.profile': 'Profile',
      'nav.staff_portal': 'Staff Portal',

      // Settings Screen
      'settings.title': 'Settings',
      'settings.statistics': 'STATISTICS',
      'settings.account': 'ACCOUNT',
      'settings.preferences': 'PREFERENCES',
      'settings.support': 'SUPPORT',
      'settings.about': 'ABOUT',

      'settings.attendance_stat': 'Attendance',
      'settings.leave_stat': 'Leave Left',
      'settings.perf_stat': 'Performance',

      'settings.staff_profile': 'Staff Profile',
      'settings.staff_profile_sub': 'Personal info, department & job role',
      'settings.security': 'Security & Password',
      'settings.security_sub': 'Password, credentials & sessions',

      'settings.push_notifications': 'Push Notifications',
      'settings.dark_mode': 'Dark Mode',
      'settings.language': 'Language',

      'settings.help_center': 'Help Center',
      'settings.help_center_sub': 'FAQs, guides & staff portal manuals',
      'settings.contact_support': 'Contact HR & IT Support',
      'settings.contact_support_sub': 'Direct line for internal assistance',

      'settings.terms': 'Terms of Service',
      'settings.privacy': 'Privacy Policy',
      'settings.about_teams': 'About Ngam Teams',
      'settings.sign_out': 'Sign Out',
      'settings.sign_out_confirm': 'Are you sure you want to sign out from Ngam Teams on this device?',
      'settings.cancel': 'Cancel',
      'settings.made_with_love': 'Made with ❤️ for Ngam Ecosystem',
      'settings.choose_language': 'Choose Language',

      // Profile Screen
      'profile.title': 'Staff Profile',
      'profile.info_panel': 'Staff Information',
      'profile.email': 'Work Email',
      'profile.phone': 'Mobile Phone',
      'profile.staff_id': 'Staff ID',
      'profile.department': 'Department',
      'profile.designation': 'Designation',
      'profile.joined': 'Date Joined',
      'profile.reporting_line': 'Reporting Line',
      'profile.office_base': 'Office Base',
      'profile.security_clearance': 'System & Security Clearance',
      'profile.door_pass': 'Door Access Pass',
      'profile.git_access': 'Git Repositories',
      'profile.cloud_access': 'Cloud Console (GCP & Supabase)',
      'profile.fuel_card': 'Corporate Fuel Card',
      'profile.granted': 'Granted',
      'profile.active': 'Active Staff',
      'profile.full_time': 'Full-Time',
      'profile.request_update': 'Request Info Correction',
      'profile.submit_request': 'Submit Request',
      'profile.update_hint': 'Specify changes to your personal contact details, residential address, or bank account for HR review.',

      // Auth / Login
      'auth.portal_badge': 'STAFF PORTAL',
      'auth.welcome_title': 'Ngam Teams',
      'auth.welcome_subtitle': 'Sign in to access attendance, leaves & operations',
      'auth.email': 'Work Email',
      'auth.email_hint': 'e.g. ariff@ngam.my',
      'auth.password': 'Password',
      'auth.password_hint': 'Enter your password',
      'auth.remember_me': 'Remember this device',
      'auth.forgot_password': 'Forgot password?',
      'auth.sign_in': 'Sign In to Portal',
      'auth.signing_in': 'Signing in...',
      'auth.demo_sign_in': '⚡ Quick Demo Sign-In',
      'auth.demo_account_hint': 'Sign in as Ariff Danial (Lead Flutter Dev)',
      'auth.fill_demo': 'Auto-fill Demo Credentials',
      'auth.error_empty': 'Please enter both your work email and password.',
      'auth.error_invalid_email': 'Please enter a valid work email address.',
      'auth.contact_hr': 'Need an account or access? Contact HR & IT Operations',
      'auth.security_notice': 'Protected by Ngam Enterprise Identity & Clearance',
      'auth.forgot_dialog_title': 'Password Reset Help',
      'auth.forgot_dialog_desc': 'Staff account credentials are managed centrally. Please reach out to your HR administrator or IT Helpdesk to request a password reset.',
      'auth.close': 'Close',
    },
    'ms': {
      // Navigation
      'nav.home': 'Laman',
      'nav.notices': 'Notis',
      'nav.attend': 'Kehadiran',
      'nav.leave': 'Cuti',
      'nav.settings': 'Tetapan',
      'nav.profile': 'Profil',
      'nav.staff_portal': 'Portal Staf',

      // Settings Screen
      'settings.title': 'Tetapan',
      'settings.statistics': 'STATISTIK',
      'settings.account': 'AKAUN',
      'settings.preferences': 'PILIHAN',
      'settings.support': 'SOKONGAN',
      'settings.about': 'TENTANG KAMI',

      'settings.attendance_stat': 'Kehadiran',
      'settings.leave_stat': 'Baki Cuti',
      'settings.perf_stat': 'Prestasi',

      'settings.staff_profile': 'Profil Staf',
      'settings.staff_profile_sub': 'Maklumat peribadi, jabatan & peranan kerja',
      'settings.security': 'Keselamatan & Kata Laluan',
      'settings.security_sub': 'Kata laluan, kredensial & sesi log masuk',

      'settings.push_notifications': 'Notifikasi Tolak',
      'settings.dark_mode': 'Mod Gelap',
      'settings.language': 'Bahasa',

      'settings.help_center': 'Pusat Bantuan',
      'settings.help_center_sub': 'Soalan lazim, panduan & manual portal staf',
      'settings.contact_support': 'Hubungi HR & Sokongan IT',
      'settings.contact_support_sub': 'Talian terus untuk bantuan dalaman',

      'settings.terms': 'Syarat Perkhidmatan',
      'settings.privacy': 'Dasar Privasi',
      'settings.about_teams': 'Tentang Ngam Teams',
      'settings.sign_out': 'Log Keluar',
      'settings.sign_out_confirm': 'Adakah anda pasti mahu log keluar dari Ngam Teams pada peranti ini?',
      'settings.cancel': 'Batal',
      'settings.made_with_love': 'Dibuat dengan ❤️ untuk Ekosistem Ngam',
      'settings.choose_language': 'Pilih Bahasa',

      // Profile Screen
      'profile.title': 'Profil Staf',
      'profile.info_panel': 'Maklumat Staf',
      'profile.email': 'Emel Kerja',
      'profile.phone': 'Telefon Bimbit',
      'profile.staff_id': 'ID Staf',
      'profile.department': 'Jabatan',
      'profile.designation': 'Jawatan',
      'profile.joined': 'Tarikh Mula',
      'profile.reporting_line': 'Penyelia Bertanggungjawab',
      'profile.office_base': 'Pusat Operasi',
      'profile.security_clearance': 'Pelepasan Sistem & Keselamatan',
      'profile.door_pass': 'Pas Akses Pintu',
      'profile.git_access': 'Repositori Git',
      'profile.cloud_access': 'Konsol Awan (GCP & Supabase)',
      'profile.fuel_card': 'Kad Bahan Api Korporat',
      'profile.granted': 'Dibenarkan',
      'profile.active': 'Staf Aktif',
      'profile.full_time': 'Sepenuh Masa',
      'profile.request_update': 'Mohon Pembetulan Maklumat',
      'profile.submit_request': 'Hantar Permohonan',
      'profile.update_hint': 'Nyatakan pindaan maklumat hubungan, alamat tempat tinggal, atau akaun bank untuk semakan pihak HR.',

      // Auth / Login
      'auth.portal_badge': 'PORTAL STAF',
      'auth.welcome_title': 'Ngam Teams',
      'auth.welcome_subtitle': 'Log masuk untuk akses kehadiran, cuti & operasi',
      'auth.email': 'Emel Kerja',
      'auth.email_hint': 'cth. ariff@ngam.my',
      'auth.password': 'Kata Laluan',
      'auth.password_hint': 'Masukkan kata laluan anda',
      'auth.remember_me': 'Ingat peranti ini',
      'auth.forgot_password': 'Lupa kata laluan?',
      'auth.sign_in': 'Log Masuk ke Portal',
      'auth.signing_in': 'Sedang log masuk...',
      'auth.demo_sign_in': '⚡ Log Masuk Pantas Demo',
      'auth.demo_account_hint': 'Log masuk sebagai Ariff Danial (Lead Flutter Dev)',
      'auth.fill_demo': 'Isi Kredensial Demo',
      'auth.error_empty': 'Sila masukkan emel kerja dan kata laluan anda.',
      'auth.error_invalid_email': 'Sila masukkan alamat emel kerja yang sah.',
      'auth.contact_hr': 'Perlukan akaun atau akses? Hubungi Operasi HR & IT',
      'auth.security_notice': 'Dilindungi oleh Identiti & Pelepasan Perusahaan Ngam',
      'auth.forgot_dialog_title': 'Bantuan Tetapan Kata Laluan',
      'auth.forgot_dialog_desc': 'Kredensial akaun staf diuruskan secara berpusat. Sila hubungi pentadbir HR atau Meja Bantuan IT anda untuk menetapkan semula kata laluan.',
      'auth.close': 'Tutup',
    },
  };

  static String tr(String key, [String? langCode]) {
    final lang = langCode ?? AppSettings.instance.languageCode;
    final map = _strings[lang] ?? _strings['en']!;
    return map[key] ?? _strings['en']?[key] ?? key;
  }
}

extension AppTranslationsExtension on BuildContext {
  String tr(String key) => AppTranslations.tr(key, AppSettings.instance.languageCode);
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
