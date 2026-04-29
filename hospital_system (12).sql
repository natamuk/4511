-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- 主機： 127.0.0.1
-- 產生時間： 2026-04-29 21:19:51
-- 伺服器版本： 10.4.32-MariaDB
-- PHP 版本： 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- 資料庫： `hospital_system`
--

-- --------------------------------------------------------

--
-- 資料表結構 `admin`
--

CREATE TABLE `admin` (
  `id` bigint(20) NOT NULL COMMENT 'Admin ID',
  `username` varchar(50) NOT NULL COMMENT 'Username',
  `password` varchar(100) NOT NULL COMMENT 'Password',
  `real_name` varchar(50) NOT NULL COMMENT 'Real Name',
  `phone` varchar(20) DEFAULT NULL COMMENT 'Phone Number',
  `email` varchar(100) DEFAULT NULL COMMENT 'Email',
  `avatar` varchar(255) DEFAULT NULL COMMENT 'Avatar',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT 'Status: 1=active, 0=disabled',
  `create_time` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Create Time',
  `update_time` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Update Time'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Admin Table';

--
-- 傾印資料表的資料 `admin`
--

INSERT INTO `admin` (`id`, `username`, `password`, `real_name`, `phone`, `email`, `avatar`, `status`, `create_time`, `update_time`) VALUES
(1, 'admin', '123456', 'System Admin', '13800000001', 'admin@hospital.com', NULL, 1, '2026-04-02 23:04:55', '2026-04-02 23:04:55'),
(2, 'superadmin', '123456', 'Super Admin', '13800000002', 'superadmin@hospital.com', NULL, 1, '2026-04-02 23:04:55', '2026-04-02 23:04:55');

-- --------------------------------------------------------

--
-- 資料表結構 `clinic`
--

CREATE TABLE `clinic` (
  `id` bigint(20) NOT NULL COMMENT 'Clinic ID',
  `clinic_name` varchar(100) NOT NULL COMMENT 'Clinic Name',
  `location` varchar(200) DEFAULT NULL COMMENT 'Location',
  `description` text DEFAULT NULL COMMENT 'Description',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT 'Status: 1=active, 0=disabled',
  `sort_num` int(11) NOT NULL DEFAULT 0 COMMENT 'Sort Order',
  `create_time` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Create Time',
  `update_time` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Update Time'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Clinic Table';

--
-- 傾印資料表的資料 `clinic`
--

INSERT INTO `clinic` (`id`, `clinic_name`, `location`, `description`, `status`, `sort_num`, `create_time`, `update_time`) VALUES
(1, 'Chai Wan Community Clinic', 'Hong Kong Chai Wan', 'General practice, vaccination, chronic disease follow-up', 1, 1, '2026-04-05 00:01:59', '2026-04-30 02:59:50'),
(2, 'Tseung Kwan O Community Clinic', 'New Territories Tseung Kwan O', 'Health screening, pediatrics, family medicine', 1, 2, '2026-04-05 00:01:59', '2026-04-05 00:01:59'),
(3, 'Sha Tin Community Clinic', 'New Territories Sha Tin', 'General practice and chronic disease management', 1, 3, '2026-04-05 00:01:59', '2026-04-05 00:01:59'),
(4, 'Tuen Mun Community Clinic', 'New Territories Tuen Mun', 'General practice and geriatrics', 1, 4, '2026-04-05 00:01:59', '2026-04-05 00:01:59'),
(5, 'Kowloon Bay Community Clinic', 'Kowloon Bay', 'Family medicine and outpatient service', 1, 5, '2026-04-05 00:01:59', '2026-04-05 00:01:59');

-- --------------------------------------------------------

--
-- 資料表結構 `clinic_time_slot`
--

CREATE TABLE `clinic_time_slot` (
  `id` bigint(20) NOT NULL COMMENT 'Time Slot ID',
  `clinic_id` bigint(20) NOT NULL COMMENT 'Clinic ID',
  `period` varchar(20) NOT NULL COMMENT 'Period: morning, afternoon, evening',
  `slot_time` varchar(20) NOT NULL COMMENT 'Slot Time',
  `capacity` int(11) NOT NULL DEFAULT 5 COMMENT 'Maximum Patients',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT 'Status: 1=active, 0=disabled',
  `create_time` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Create Time',
  `update_time` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Update Time'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Clinic Time Slot Table';

--
-- 傾印資料表的資料 `clinic_time_slot`
--

INSERT INTO `clinic_time_slot` (`id`, `clinic_id`, `period`, `slot_time`, `capacity`, `status`, `create_time`, `update_time`) VALUES
(62, 1, 'morning', '09:00', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(63, 1, 'morning', '09:30', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(64, 1, 'morning', '10:00', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(65, 1, 'morning', '10:30', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(66, 1, 'morning', '11:00', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(67, 1, 'morning', '11:30', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(68, 1, 'afternoon', '13:00', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(69, 1, 'afternoon', '13:30', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(70, 1, 'afternoon', '14:00', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(71, 1, 'afternoon', '14:30', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(72, 1, 'afternoon', '15:00', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(73, 1, 'afternoon', '15:30', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(74, 1, 'evening', '16:00', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(75, 1, 'evening', '16:30', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(76, 1, 'evening', '17:00', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(77, 1, 'evening', '17:30', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(78, 2, 'morning', '09:30', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(79, 2, 'morning', '10:00', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(80, 2, 'morning', '10:30', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(81, 2, 'morning', '11:00', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(82, 2, 'afternoon', '13:00', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(83, 2, 'afternoon', '13:30', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(84, 2, 'afternoon', '14:00', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(85, 2, 'afternoon', '15:30', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(86, 2, 'evening', '16:00', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(87, 2, 'evening', '16:30', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(89, 3, 'morning', '09:00', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(90, 3, 'morning', '09:30', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(91, 3, 'morning', '10:30', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(92, 3, 'morning', '11:00', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(93, 3, 'afternoon', '13:00', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(94, 3, 'afternoon', '13:30', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(95, 3, 'afternoon', '14:00', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(96, 3, 'afternoon', '14:30', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(99, 3, 'evening', '16:00', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(100, 4, 'morning', '09:00', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(101, 4, 'morning', '09:30', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(102, 4, 'morning', '10:00', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(103, 4, 'morning', '11:00', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(104, 4, 'morning', '11:30', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(105, 4, 'afternoon', '13:30', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(106, 4, 'afternoon', '14:00', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(107, 4, 'afternoon', '14:30', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(108, 4, 'afternoon', '15:30', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(109, 4, 'evening', '16:00', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(110, 4, 'evening', '16:30', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(111, 4, 'evening', '17:00', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(112, 5, 'morning', '09:00', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(113, 5, 'morning', '09:30', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(114, 5, 'morning', '10:00', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(115, 5, 'morning', '10:30', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(116, 5, 'afternoon', '13:00', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(117, 5, 'afternoon', '13:30', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(118, 5, 'afternoon', '14:00', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(119, 5, 'afternoon', '14:30', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(120, 5, 'evening', '16:00', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(121, 5, 'evening', '16:30', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(122, 5, 'evening', '17:00', 5, 1, '2026-04-05 00:01:41', '2026-04-05 01:14:18'),
(123, 2, 'morning', '09:00', 5, 1, '2026-04-05 01:12:46', '2026-04-05 01:14:18'),
(124, 3, 'morning', '10:00', 5, 1, '2026-04-05 01:12:46', '2026-04-05 01:14:18'),
(125, 4, 'morning', '10:30', 5, 1, '2026-04-05 01:12:46', '2026-04-05 01:14:18'),
(126, 5, 'morning', '11:00', 5, 1, '2026-04-05 01:12:46', '2026-04-05 01:14:18'),
(127, 2, 'morning', '11:30', 5, 1, '2026-04-05 01:12:46', '2026-04-05 01:14:18'),
(128, 3, 'morning', '11:30', 5, 1, '2026-04-05 01:12:46', '2026-04-05 01:14:18'),
(129, 5, 'morning', '11:30', 5, 1, '2026-04-05 01:12:46', '2026-04-05 01:14:18'),
(130, 4, 'afternoon', '13:00', 5, 1, '2026-04-05 01:12:46', '2026-04-05 01:14:18'),
(131, 2, 'afternoon', '14:30', 5, 1, '2026-04-05 01:12:46', '2026-04-05 01:14:18'),
(132, 2, 'afternoon', '15:00', 5, 1, '2026-04-05 01:12:46', '2026-04-05 01:14:18'),
(133, 3, 'afternoon', '15:00', 5, 1, '2026-04-05 01:12:46', '2026-04-05 01:14:18'),
(134, 4, 'afternoon', '15:00', 5, 1, '2026-04-05 01:12:46', '2026-04-05 01:14:18'),
(135, 5, 'afternoon', '15:00', 5, 1, '2026-04-05 01:12:46', '2026-04-05 01:14:18'),
(136, 3, 'afternoon', '15:30', 5, 1, '2026-04-05 01:12:46', '2026-04-05 01:14:18'),
(137, 5, 'afternoon', '15:30', 5, 1, '2026-04-05 01:12:46', '2026-04-05 01:14:18'),
(138, 3, 'evening', '16:30', 5, 1, '2026-04-05 01:12:46', '2026-04-05 01:14:18'),
(139, 2, 'evening', '17:00', 5, 1, '2026-04-05 01:12:46', '2026-04-05 01:14:18'),
(140, 3, 'evening', '17:00', 5, 1, '2026-04-05 01:12:46', '2026-04-05 01:14:18'),
(141, 2, 'evening', '17:30', 5, 1, '2026-04-05 01:12:46', '2026-04-05 01:14:18'),
(142, 3, 'evening', '17:30', 5, 1, '2026-04-05 01:12:46', '2026-04-05 01:14:18'),
(143, 4, 'evening', '17:30', 5, 1, '2026-04-05 01:12:46', '2026-04-05 01:14:18'),
(144, 5, 'evening', '17:30', 5, 1, '2026-04-05 01:12:46', '2026-04-05 01:14:18');

-- --------------------------------------------------------

--
-- 資料表結構 `consultation`
--

CREATE TABLE `consultation` (
  `id` bigint(20) NOT NULL COMMENT 'Consultation ID',
  `registration_id` bigint(20) NOT NULL COMMENT 'Registration ID',
  `patient_id` bigint(20) NOT NULL COMMENT 'Patient ID',
  `doctor_id` bigint(20) NOT NULL COMMENT 'Doctor ID',
  `diagnosis` varchar(255) DEFAULT NULL COMMENT 'Diagnosis',
  `medical_advice` text DEFAULT NULL COMMENT 'Medical Advice',
  `prescription` text DEFAULT NULL COMMENT 'Prescription',
  `consultation_time` datetime DEFAULT NULL COMMENT 'Consultation Time',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT 'Status: 1=consulting, 2=completed',
  `create_time` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Create Time',
  `update_time` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Update Time'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Consultation Table';

--
-- 傾印資料表的資料 `consultation`
--

INSERT INTO `consultation` (`id`, `registration_id`, `patient_id`, `doctor_id`, `diagnosis`, `medical_advice`, `prescription`, `consultation_time`, `status`, `create_time`, `update_time`) VALUES
(1, 3, 3, 2, 'Appendicitis', 'Rest and follow-up', 'Pain relief medicine', '2026-03-31 21:56:15', 2, '2026-04-02 23:04:55', '2026-04-02 23:04:55'),
(2, 4, 4, 3, 'Flu', 'Drink more water and rest', 'Antiviral medicine', '2026-03-31 21:56:15', 2, '2026-04-02 23:04:55', '2026-04-02 23:04:55');

-- --------------------------------------------------------

--
-- 資料表結構 `department`
--

CREATE TABLE `department` (
  `id` bigint(20) NOT NULL COMMENT 'Department ID',
  `dept_name` varchar(100) NOT NULL COMMENT 'Department Name',
  `dept_code` varchar(50) DEFAULT NULL COMMENT 'Department Code',
  `description` text DEFAULT NULL COMMENT 'Department Description',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT 'Status: 1=active, 0=disabled',
  `sort_num` int(11) NOT NULL DEFAULT 0 COMMENT 'Sort Order',
  `create_time` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Create Time',
  `update_time` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Update Time'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Department Table';

--
-- 傾印資料表的資料 `department`
--

INSERT INTO `department` (`id`, `dept_name`, `dept_code`, `description`, `status`, `sort_num`, `create_time`, `update_time`) VALUES
(1, 'Internal Medicine', 'IM001', 'General internal medicine department', 1, 1, '2026-04-02 23:04:55', '2026-04-02 23:04:55'),
(2, 'Surgery', 'SUR001', 'General surgery department', 1, 2, '2026-04-02 23:04:55', '2026-04-02 23:04:55'),
(3, 'Pediatrics', 'PED001', 'Children healthcare department', 1, 3, '2026-04-02 23:04:55', '2026-04-02 23:04:55'),
(4, 'Gynecology', 'GYN001', 'Women healthcare department', 1, 4, '2026-04-02 23:04:55', '2026-04-02 23:04:55'),
(5, 'Dermatology', 'DER001', 'Skin disease department', 1, 5, '2026-04-02 23:04:55', '2026-04-02 23:04:55'),
(6, 'ENT', 'ENT001', 'Ear, nose and throat department', 1, 6, '2026-04-02 23:04:55', '2026-04-02 23:04:55');

-- --------------------------------------------------------

--
-- 資料表結構 `doctor`
--

CREATE TABLE `doctor` (
  `id` bigint(20) NOT NULL COMMENT 'Doctor ID',
  `username` varchar(50) NOT NULL COMMENT 'Username',
  `password` varchar(100) NOT NULL COMMENT 'Password',
  `real_name` varchar(50) NOT NULL COMMENT 'Real Name',
  `gender` tinyint(4) DEFAULT NULL COMMENT 'Gender: 1=male, 2=female',
  `phone` varchar(20) DEFAULT NULL COMMENT 'Phone Number',
  `email` varchar(100) DEFAULT NULL COMMENT 'Email',
  `title` varchar(50) DEFAULT NULL COMMENT 'Professional Title',
  `department_id` bigint(20) NOT NULL COMMENT 'Department ID',
  `clinic_id` bigint(20) DEFAULT NULL COMMENT 'Clinic ID',
  `introduction` text DEFAULT NULL COMMENT 'Introduction',
  `avatar` varchar(255) DEFAULT NULL COMMENT 'Avatar',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT 'Status: 1=active, 0=disabled',
  `register_fee` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Registration Fee',
  `create_time` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Create Time',
  `update_time` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Update Time',
  `primary_clinic_id` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Doctor Table';

--
-- 傾印資料表的資料 `doctor`
--

INSERT INTO `doctor` (`id`, `username`, `password`, `real_name`, `gender`, `phone`, `email`, `title`, `department_id`, `clinic_id`, `introduction`, `avatar`, `status`, `register_fee`, `create_time`, `update_time`, `primary_clinic_id`) VALUES
(1, 'doctor01', '123456', 'Dr. Smith', 1, '13900000001', 'smith@hospital.com', 'Chief Physician', 1, 1, 'Experienced internal medicine doctor', NULL, 1, 20.00, '2026-04-02 23:04:55', '2026-04-28 00:39:18', 1),
(2, 'doctor02', '123456', 'Dr. Johnson', 1, '13900000002', 'johnson@hospital.com', 'Associate Chief Physician', 2, 2, 'Experienced surgery doctor', NULL, 1, 25.00, '2026-04-02 23:04:55', '2026-04-28 00:49:44', 2),
(3, 'doctor03', '123456', 'Dr. Williams', 2, '13900000003', 'williams@hospital.com', 'Attending Physician', 3, 3, 'Pediatric specialist', NULL, 1, 18.00, '2026-04-02 23:04:55', '2026-04-28 00:49:46', 3),
(4, 'doctor04', '123456', 'Dr. Brown', 2, '13900000004', 'brown@hospital.com', 'Chief Physician', 4, 4, 'Gynecology specialist', NULL, 1, 22.00, '2026-04-02 23:04:55', '2026-04-28 00:49:50', 4),
(7, 'patient06', '123456', 'YU', 0, '123213213213', '123@123.com', '123', 1, NULL, NULL, 'default.png', 1, 0.00, '2026-04-30 02:42:26', '2026-04-30 02:42:26', NULL);

-- --------------------------------------------------------

--
-- 資料表結構 `doctor_attendance`
--

CREATE TABLE `doctor_attendance` (
  `id` bigint(20) NOT NULL COMMENT 'Attendance ID',
  `doctor_id` bigint(20) NOT NULL COMMENT 'Doctor ID',
  `checkin_time` datetime NOT NULL COMMENT 'Check-in Time',
  `checkout_time` datetime DEFAULT NULL COMMENT 'Check-out Time',
  `date` date NOT NULL COMMENT 'Attendance Date',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '1=checked in, 2=checked out'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Doctor Attendance Record';

--
-- 傾印資料表的資料 `doctor_attendance`
--

INSERT INTO `doctor_attendance` (`id`, `doctor_id`, `checkin_time`, `checkout_time`, `date`, `status`) VALUES
(1, 3, '2026-04-25 02:58:49', NULL, '2026-04-25', 1),
(2, 1, '2026-04-29 22:09:51', NULL, '2026-04-29', 1),
(3, 3, '2026-04-29 22:18:09', NULL, '2026-04-29', 1),
(4, 1, '2026-04-30 01:42:39', NULL, '2026-04-30', 1),
(5, 3, '2026-04-30 01:42:53', NULL, '2026-04-30', 1),
(6, 2, '2026-04-30 02:01:08', NULL, '2026-04-30', 1),
(7, 4, '2026-04-30 02:01:31', NULL, '2026-04-30', 1);

-- --------------------------------------------------------

--
-- 資料表結構 `doctor_issue`
--

CREATE TABLE `doctor_issue` (
  `id` bigint(20) NOT NULL COMMENT 'Issue ID',
  `doctor_id` bigint(20) NOT NULL COMMENT 'Doctor ID',
  `issue_type` varchar(100) NOT NULL COMMENT 'Issue Type',
  `clinic_name` varchar(100) NOT NULL COMMENT 'Clinic Name',
  `detail` text NOT NULL COMMENT 'Issue Detail',
  `status` varchar(50) NOT NULL DEFAULT 'Open' COMMENT 'Status',
  `created_at` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Created At',
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Updated At'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Doctor Issue Table';

--
-- 傾印資料表的資料 `doctor_issue`
--

INSERT INTO `doctor_issue` (`id`, `doctor_id`, `issue_type`, `clinic_name`, `detail`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 'Cancellation', 'Chai Wan Community Clinic', 'Appointment #23 cancelled. Reason: 123', 'Open', '2026-04-29 23:11:53', '2026-04-29 23:11:53'),
(2, 1, 'Cancellation', 'Chai Wan Community Clinic', 'Appointment #24 cancelled. Reason: 8', 'Open', '2026-04-29 23:18:50', '2026-04-29 23:18:50'),
(3, 1, 'Cancellation', 'Chai Wan Community Clinic', 'Appointment #26 cancelled. Reason: 12321312', 'Open', '2026-04-29 23:23:13', '2026-04-29 23:23:13'),
(4, 1, 'Cancellation', 'Chai Wan Community Clinic', 'Appointment #33 cancelled. Reason: 1241234', 'Open', '2026-04-30 00:10:03', '2026-04-30 00:10:03'),
(5, 1, 'Cancellation', 'Chai Wan Community Clinic', 'Appointment #34 cancelled. Reason: 1232131', 'Open', '2026-04-30 00:30:36', '2026-04-30 00:30:36'),
(6, 1, 'Cancellation', 'Chai Wan Community Clinic', 'Appointment #34 cancelled. Reason: 1232132131', 'Open', '2026-04-30 00:30:38', '2026-04-30 00:30:38'),
(7, 1, 'Cancellation', 'Chai Wan Community Clinic', 'Appointment #35 cancelled. Reason: 5', 'Open', '2026-04-30 00:38:45', '2026-04-30 00:38:45'),
(8, 1, 'Manual Report', '', '555', 'Open', '2026-04-30 00:39:42', '2026-04-30 00:39:42'),
(9, 1, 'Manual Report', '', '123213213', 'Open', '2026-04-30 00:42:58', '2026-04-30 00:42:58'),
(10, 1, 'Manual Report', '', 'qweqwewqewqe', 'Open', '2026-04-30 00:43:04', '2026-04-30 00:43:04'),
(11, 1, 'Cancellation', 'Chai Wan Community Clinic', 'Appointment #36 cancelled. Reason: 123123213', 'Open', '2026-04-30 00:44:18', '2026-04-30 00:44:18'),
(12, 1, 'Cancellation', 'Chai Wan Community Clinic', 'Appointment #37 cancelled. Reason: 123213', 'Open', '2026-04-30 00:44:59', '2026-04-30 00:44:59'),
(13, 1, 'Cancellation', 'Chai Wan Community Clinic', 'Appointment #38 cancelled. Reason: 123213', 'Open', '2026-04-30 00:46:51', '2026-04-30 00:46:51'),
(14, 1, 'Manual Report', '', '12313', 'Open', '2026-04-30 00:47:34', '2026-04-30 00:47:34'),
(15, 1, 'Cancellation', 'Chai Wan Community Clinic', 'Appointment #39 cancelled. Reason: 12414124', 'Open', '2026-04-30 00:48:54', '2026-04-30 00:48:54'),
(16, 1, 'Cancellation', 'Chai Wan Community Clinic', 'Appointment #40 cancelled. Reason: 243525', 'Open', '2026-04-30 02:03:10', '2026-04-30 02:03:10'),
(17, 1, 'Doctor Absent', '', '1414124214', 'Open', '2026-04-30 02:03:32', '2026-04-30 02:03:32'),
(18, 1, 'Cancellation', 'Chai Wan Community Clinic', 'Appointment #42 cancelled. Reason: 52525', 'Open', '2026-04-30 02:06:57', '2026-04-30 02:06:57'),
(19, 1, 'Cancellation', 'Chai Wan Community Clinic', 'Appointment #41 cancelled. Reason: 214241', 'Open', '2026-04-30 02:06:59', '2026-04-30 02:06:59'),
(20, 1, 'Cancellation', 'Chai Wan Community Clinic', 'Appointment #43 cancelled. Reason: 124214214', 'Open', '2026-04-30 02:07:02', '2026-04-30 02:07:02'),
(21, 1, 'Cancellation', 'Chai Wan Community Clinic', 'Appointment #46 cancelled. Reason: jaskldjsad', 'Open', '2026-04-30 02:34:10', '2026-04-30 02:34:10'),
(22, 1, 'Cancellation', 'Chai Wan Community Clinic', 'Appointment #47 cancelled. Reason: 23532532', 'Open', '2026-04-30 02:56:54', '2026-04-30 02:56:54'),
(23, 1, 'Cancellation', 'Chai Wan Community Clinic', 'Appointment #48 cancelled. Reason: 455', 'Open', '2026-04-30 03:15:15', '2026-04-30 03:15:15');

-- --------------------------------------------------------

--
-- 資料表結構 `hospitalization`
--

CREATE TABLE `hospitalization` (
  `id` bigint(20) NOT NULL COMMENT 'Hospitalization ID',
  `patient_id` bigint(20) NOT NULL COMMENT 'Patient ID',
  `doctor_id` bigint(20) NOT NULL COMMENT 'Doctor ID',
  `registration_id` bigint(20) DEFAULT NULL COMMENT 'Registration ID',
  `admission_no` varchar(50) NOT NULL COMMENT 'Admission Number',
  `ward_name` varchar(100) DEFAULT NULL COMMENT 'Ward Name',
  `room_no` varchar(50) DEFAULT NULL COMMENT 'Room Number',
  `bed_no` varchar(50) DEFAULT NULL COMMENT 'Bed Number',
  `diagnosis` varchar(255) DEFAULT NULL COMMENT 'Diagnosis',
  `admission_reason` text DEFAULT NULL COMMENT 'Admission Reason',
  `admission_date` date NOT NULL COMMENT 'Admission Date',
  `discharge_date` date DEFAULT NULL COMMENT 'Discharge Date',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT 'Status: 1=admitted, 2=discharged',
  `create_time` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Create Time',
  `update_time` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Update Time'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Hospitalization Table';

--
-- 傾印資料表的資料 `hospitalization`
--

INSERT INTO `hospitalization` (`id`, `patient_id`, `doctor_id`, `registration_id`, `admission_no`, `ward_name`, `room_no`, `bed_no`, `diagnosis`, `admission_reason`, `admission_date`, `discharge_date`, `status`, `create_time`, `update_time`) VALUES
(1, 3, 2, 3, 'ADM202603310001', 'Ward A', '101', '1', 'Appendicitis', 'Surgery observation', '2026-03-31', NULL, 1, '2026-04-02 23:04:55', '2026-04-02 23:04:55'),
(2, 4, 3, 4, 'ADM202603310002', 'Ward B', '202', '2', 'Severe flu', 'Need observation', '2026-03-31', NULL, 1, '2026-04-02 23:04:55', '2026-04-02 23:04:55');

-- --------------------------------------------------------

--
-- 資料表結構 `notice`
--

CREATE TABLE `notice` (
  `id` bigint(20) NOT NULL COMMENT 'Notice ID',
  `title` varchar(200) NOT NULL COMMENT 'Title',
  `content` text NOT NULL COMMENT 'Content',
  `publisher_id` bigint(20) NOT NULL COMMENT 'Publisher ID',
  `publisher_type` tinyint(4) NOT NULL COMMENT 'Publisher Type: 1=admin, 2=doctor',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT 'Status: 1=published, 0=draft',
  `publish_time` datetime DEFAULT NULL COMMENT 'Publish Time',
  `create_time` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Create Time',
  `update_time` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Update Time'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Notice Table';

--
-- 傾印資料表的資料 `notice`
--

INSERT INTO `notice` (`id`, `title`, `content`, `publisher_id`, `publisher_type`, `status`, `publish_time`, `create_time`, `update_time`) VALUES
(1, 'Hospital Opening Notice', 'The hospital system is now online.', 1, 1, 1, '2026-03-31 21:56:15', '2026-04-02 23:04:55', '2026-04-02 23:04:55'),
(2, 'Outpatient Schedule Update', 'Some doctors have updated schedules today.', 1, 1, 1, '2026-03-31 21:56:15', '2026-04-02 23:04:55', '2026-04-02 23:04:55'),
(3, 'Holiday Arrangement', 'Registration service will be adjusted during holidays.', 1, 1, 1, '2026-03-31 21:56:15', '2026-04-02 23:04:55', '2026-04-02 23:04:55');

-- --------------------------------------------------------

--
-- 資料表結構 `operation_log`
--

CREATE TABLE `operation_log` (
  `id` bigint(20) NOT NULL COMMENT 'Operation Log ID',
  `user_type` tinyint(4) NOT NULL COMMENT 'User Type: 1=admin, 2=doctor, 3=patient',
  `user_id` bigint(20) NOT NULL COMMENT 'User ID',
  `operation` varchar(100) NOT NULL COMMENT 'Operation',
  `detail` text DEFAULT NULL COMMENT 'Detail',
  `ip_address` varchar(50) DEFAULT NULL COMMENT 'IP Address',
  `create_time` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Create Time'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Operation Log Table';

--
-- 傾印資料表的資料 `operation_log`
--

INSERT INTO `operation_log` (`id`, `user_type`, `user_id`, `operation`, `detail`, `ip_address`, `create_time`) VALUES
(1, 1, 1, 'Login', 'Admin login success', '127.0.0.1', '2026-04-02 23:04:55'),
(2, 2, 1, 'Call Patient', 'Doctor called patient 1', '127.0.0.1', '2026-04-02 23:04:55'),
(3, 3, 1, 'Register', 'Patient registered successfully', '127.0.0.1', '2026-04-02 23:04:55'),
(4, 1, 1, 'Publish Notice', 'Admin published a notice', '127.0.0.1', '2026-04-02 23:04:55'),
(5, 3, 2, 'Recharge', 'Patient recharged account', '127.0.0.1', '2026-04-02 23:04:55');

-- --------------------------------------------------------

--
-- 資料表結構 `patient`
--

CREATE TABLE `patient` (
  `id` bigint(20) NOT NULL COMMENT 'Patient ID',
  `username` varchar(50) NOT NULL COMMENT 'Username',
  `password` varchar(100) NOT NULL COMMENT 'Password',
  `real_name` varchar(50) NOT NULL COMMENT 'Real Name',
  `gender` tinyint(4) DEFAULT NULL COMMENT 'Gender: 1=male, 2=female',
  `phone` varchar(20) DEFAULT NULL COMMENT 'Phone Number',
  `email` varchar(100) DEFAULT NULL COMMENT 'Email',
  `id_card` varchar(20) DEFAULT NULL COMMENT 'ID Card Number',
  `birthday` date DEFAULT NULL COMMENT 'Birthday',
  `address` varchar(255) DEFAULT NULL COMMENT 'Address',
  `avatar` varchar(255) DEFAULT NULL COMMENT 'Avatar',
  `balance` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Account Balance',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT 'Status: 1=active, 0=disabled',
  `create_time` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Create Time',
  `update_time` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Update Time'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Patient Table';

--
-- 傾印資料表的資料 `patient`
--

INSERT INTO `patient` (`id`, `username`, `password`, `real_name`, `gender`, `phone`, `email`, `id_card`, `birthday`, `address`, `avatar`, `balance`, `status`, `create_time`, `update_time`) VALUES
(1, 'patient01', '123456', 'Alice', 2, '13700000001', 'alice@example.com', 'P100000000001', '1995-03-10', 'New York', NULL, 80.00, 1, '2026-04-02 23:04:55', '2026-04-26 03:31:15'),
(2, 'patient02', '123456', 'Bob', 1, '13700000002', 'bob@example.com', 'P100000000002', '1992-07-18', 'Los Angeles', NULL, 150.00, 1, '2026-04-02 23:04:55', '2026-04-03 00:57:59'),
(3, 'patient03', '123456', 'Charlie', 1, '13700000003', 'charlie@example.com', 'P100000000003', '1988-11-22', 'Chicago', NULL, 300.00, 1, '2026-04-02 23:04:55', '2026-04-03 00:57:59'),
(4, 'patient04', '123456', 'Diana', 2, '13700000004', 'diana@example.com', 'P100000000004', '2000-01-05', 'Houston', NULL, 120.00, 1, '2026-04-02 23:04:55', '2026-04-03 00:57:59'),
(5, 'patient05', '123456', 'Ethan', 1, '13700000005', 'ethan@example.com', 'P100000000005', '1998-09-30', 'Phoenix', NULL, 80.00, 1, '2026-04-02 23:04:55', '2026-04-03 00:57:59');

-- --------------------------------------------------------

--
-- 資料表結構 `patient_favorite_clinic`
--

CREATE TABLE `patient_favorite_clinic` (
  `id` bigint(20) NOT NULL,
  `patient_id` bigint(20) NOT NULL,
  `clinic_id` bigint(20) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- 資料表結構 `queue`
--

CREATE TABLE `queue` (
  `id` bigint(20) NOT NULL COMMENT 'Queue ID',
  `patient_id` bigint(20) NOT NULL COMMENT 'Patient ID',
  `doctor_id` bigint(20) DEFAULT NULL COMMENT 'Doctor ID',
  `clinic_id` bigint(20) NOT NULL COMMENT 'Clinic ID',
  `queue_no` varchar(20) NOT NULL COMMENT 'Queue Number',
  `status` varchar(20) NOT NULL DEFAULT 'waiting' COMMENT 'Status: waiting, called, skipped, completed',
  `called_time` datetime DEFAULT NULL COMMENT 'Called Time',
  `created_time` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Created Time',
  `updated_time` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Updated Time'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Queue Table';

--
-- 傾印資料表的資料 `queue`
--

INSERT INTO `queue` (`id`, `patient_id`, `doctor_id`, `clinic_id`, `queue_no`, `status`, `called_time`, `created_time`, `updated_time`) VALUES
(6, 1, NULL, 1, 'Q20260429001', 'called', NULL, '2026-04-29 21:38:59', '2026-04-29 21:49:49'),
(7, 1, NULL, 1, 'Q20260429002', 'called', NULL, '2026-04-29 21:58:15', '2026-04-29 22:16:00'),
(8, 2, NULL, 1, 'Q20260429003', 'called', NULL, '2026-04-29 21:58:32', '2026-04-29 22:16:00'),
(9, 2, NULL, 1, 'Q20260429004', 'called', NULL, '2026-04-29 22:23:35', '2026-04-29 23:24:22'),
(10, 1, NULL, 1, 'Q20260430001', 'called', NULL, '2026-04-30 00:49:22', '2026-04-30 02:37:07'),
(11, 1, NULL, 1, 'Q20260430002', 'called', NULL, '2026-04-30 02:37:24', '2026-04-30 02:37:43');

-- --------------------------------------------------------

--
-- 資料表結構 `recharge_record`
--

CREATE TABLE `recharge_record` (
  `id` bigint(20) NOT NULL COMMENT 'Recharge Record ID',
  `patient_id` bigint(20) NOT NULL COMMENT 'Patient ID',
  `recharge_no` varchar(50) NOT NULL COMMENT 'Recharge Number',
  `amount` decimal(10,2) NOT NULL COMMENT 'Recharge Amount',
  `before_balance` decimal(10,2) NOT NULL COMMENT 'Before Balance',
  `after_balance` decimal(10,2) NOT NULL COMMENT 'After Balance',
  `pay_method` varchar(50) DEFAULT NULL COMMENT 'Payment Method',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT 'Status: 1=success, 0=failed',
  `create_time` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Create Time',
  `update_time` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Update Time'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Recharge Record Table';

--
-- 傾印資料表的資料 `recharge_record`
--

INSERT INTO `recharge_record` (`id`, `patient_id`, `recharge_no`, `amount`, `before_balance`, `after_balance`, `pay_method`, `status`, `create_time`, `update_time`) VALUES
(1, 1, 'RC202603310001', 100.00, 100.00, 200.00, 'Cash', 1, '2026-04-02 23:04:55', '2026-04-02 23:04:55'),
(2, 2, 'RC202603310002', 50.00, 100.00, 150.00, 'Card', 1, '2026-04-02 23:04:55', '2026-04-02 23:04:55'),
(3, 3, 'RC202603310003', 200.00, 100.00, 300.00, 'WeChat Pay', 1, '2026-04-02 23:04:55', '2026-04-02 23:04:55'),
(4, 4, 'RC202603310004', 20.00, 100.00, 120.00, 'Alipay', 1, '2026-04-02 23:04:55', '2026-04-02 23:04:55'),
(5, 5, 'RC202603310005', 80.00, 0.00, 80.00, 'Cash', 1, '2026-04-02 23:04:55', '2026-04-02 23:04:55');

-- --------------------------------------------------------

--
-- 資料表結構 `registration`
--

CREATE TABLE `registration` (
  `id` bigint(20) NOT NULL COMMENT 'Registration ID',
  `reg_no` varchar(50) NOT NULL COMMENT 'Registration Number',
  `patient_id` bigint(20) NOT NULL COMMENT 'Patient ID',
  `clinic_id` bigint(20) NOT NULL,
  `doctor_id` bigint(20) NOT NULL COMMENT 'Doctor ID',
  `department_id` bigint(20) NOT NULL COMMENT 'Department ID',
  `schedule_id` bigint(20) DEFAULT NULL,
  `reg_date` date NOT NULL COMMENT 'Registration Date',
  `slot_time` varchar(20) DEFAULT NULL COMMENT 'Appointment time slot, such as 09:00',
  `queue_no` int(11) NOT NULL COMMENT 'Queue Number',
  `fee` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Registration Fee',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT 'Status: 1=booked, 2=cancelled, 3=called, 4=consulting, 5=completed, 6=transferred',
  `cancel_time` datetime DEFAULT NULL COMMENT 'Cancel Time',
  `call_time` datetime DEFAULT NULL COMMENT 'Call Time',
  `create_time` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Create Time',
  `update_time` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Update Time',
  `cancel_reason` varchar(255) DEFAULT NULL COMMENT 'Cancel Reason'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Registration Table';

--
-- 傾印資料表的資料 `registration`
--

INSERT INTO `registration` (`id`, `reg_no`, `patient_id`, `clinic_id`, `doctor_id`, `department_id`, `schedule_id`, `reg_date`, `slot_time`, `queue_no`, `fee`, `status`, `cancel_time`, `call_time`, `create_time`, `update_time`, `cancel_reason`) VALUES
(12, 'REG1777445518110', 1, 1, 1, 1, NULL, '2026-05-01', '09:00', 1, 20.00, 2, '2026-04-29 21:04:01', NULL, '2026-04-29 14:51:58', '2026-04-29 21:04:01', NULL),
(13, 'REG1777458576519', 1, 1, 1, 1, NULL, '2026-04-30', '09:00', 1, 20.00, 2, '2026-04-29 21:03:26', NULL, '2026-04-29 18:29:36', '2026-04-29 21:03:26', NULL),
(14, 'REG1777467864831', 1, 1, 1, 1, NULL, '2026-05-07', '09:00', 1, 20.00, 2, '2026-04-29 21:04:30', NULL, '2026-04-29 21:04:24', '2026-04-29 21:04:30', NULL),
(15, 'REG1777468216807', 1, 1, 1, 1, NULL, '2026-05-01', '13:00', 2, 20.00, 2, '2026-04-29 21:10:32', NULL, '2026-04-29 21:10:16', '2026-04-29 21:10:32', NULL),
(16, 'REG1777468489006', 1, 1, 1, 1, NULL, '2026-04-30', '09:00', 2, 20.00, 3, NULL, '2026-04-29 21:15:48', '2026-04-29 21:14:49', '2026-04-29 21:15:48', NULL),
(17, 'REG1777468863945', 1, 2, 2, 2, NULL, '2026-04-30', '09:00', 1, 25.00, 2, '2026-04-29 23:19:30', NULL, '2026-04-29 21:21:03', '2026-04-29 23:19:30', NULL),
(18, 'REG1777472462666', 1, 1, 1, 1, NULL, '2026-04-30', '09:00', 3, 20.00, 2, '2026-04-29 22:21:26', NULL, '2026-04-29 22:21:02', '2026-04-29 22:21:26', NULL),
(19, 'REG1777472637148', 2, 1, 1, 1, NULL, '2026-04-30', '09:00', 4, 20.00, 2, '2026-04-29 22:29:58', NULL, '2026-04-29 22:23:57', '2026-04-29 22:29:58', NULL),
(20, 'REG1777472642543', 2, 1, 1, 1, NULL, '2026-04-30', '09:00', 5, 20.00, 2, '2026-04-29 22:37:23', NULL, '2026-04-29 22:24:02', '2026-04-29 22:37:23', NULL),
(21, 'REG1777472970548', 1, 1, 1, 1, NULL, '2026-05-01', '09:00', 3, 20.00, 2, '2026-04-29 22:47:07', NULL, '2026-04-29 22:29:30', '2026-04-29 22:47:07', '123'),
(22, 'REG1777475408438', 1, 1, 1, 1, NULL, '2026-04-29', '09:00', 1, 20.00, 2, '2026-04-29 23:10:43', NULL, '2026-04-29 23:10:08', '2026-04-29 23:10:43', NULL),
(23, 'REG1777475414843', 1, 1, 1, 1, NULL, '2026-05-01', '09:00', 4, 20.00, 2, '2026-04-29 23:11:53', NULL, '2026-04-29 23:10:14', '2026-04-29 23:11:53', '123'),
(24, 'REG1777475916450', 1, 1, 1, 1, NULL, '2026-04-29', '09:00', 2, 20.00, 2, '2026-04-29 23:18:50', NULL, '2026-04-29 23:18:36', '2026-04-29 23:18:50', '8'),
(25, 'REG1777476098328', 1, 1, 1, 1, NULL, '2026-04-29', '09:00', 3, 20.00, 2, '2026-04-29 23:21:42', NULL, '2026-04-29 23:21:38', '2026-04-29 23:21:42', NULL),
(26, 'REG1777476180064', 1, 1, 1, 1, NULL, '2026-04-29', '09:00', 4, 20.00, 2, '2026-04-29 23:23:13', NULL, '2026-04-29 23:23:00', '2026-04-29 23:23:13', '12321312'),
(27, 'REG1777476419343', 1, 1, 1, 1, NULL, '2026-04-29', '09:00', 5, 20.00, 2, '2026-04-29 23:27:04', NULL, '2026-04-29 23:26:59', '2026-04-29 23:27:04', NULL),
(28, 'REG1777477518204', 1, 1, 1, 1, NULL, '2026-04-29', '09:00', 6, 20.00, 2, '2026-04-29 23:45:21', NULL, '2026-04-29 23:45:18', '2026-04-29 23:45:21', NULL),
(29, 'REG1777478014665', 1, 1, 1, 1, NULL, '2026-04-29', '09:00', 7, 20.00, 2, '2026-04-30 00:00:40', NULL, '2026-04-29 23:53:34', '2026-04-30 00:00:40', NULL),
(30, 'REG1777478450595', 1, 1, 1, 1, NULL, '2026-04-29', '09:00', 8, 20.00, 2, '2026-04-30 00:16:45', NULL, '2026-04-30 00:00:50', '2026-04-30 00:16:45', NULL),
(31, 'REG1777478507611', 1, 1, 1, 1, NULL, '2026-04-29', '09:30', 9, 20.00, 2, '2026-04-30 00:16:56', NULL, '2026-04-30 00:01:47', '2026-04-30 00:16:56', NULL),
(32, 'REG1777478556550', 1, 1, 1, 1, NULL, '2026-04-29', '09:00', 10, 20.00, 2, '2026-04-30 00:16:54', NULL, '2026-04-30 00:02:36', '2026-04-30 00:16:54', NULL),
(33, 'REG1777478776533', 1, 1, 1, 1, NULL, '2026-05-02', '09:00', 1, 20.00, 2, '2026-04-30 00:10:03', NULL, '2026-04-30 00:06:16', '2026-04-30 00:10:03', '1241234'),
(34, 'REG1777479438733', 1, 1, 1, 1, NULL, '2026-05-02', '09:00', 2, 20.00, 2, '2026-04-30 00:30:38', NULL, '2026-04-30 00:17:18', '2026-04-30 00:30:38', '1232132131'),
(35, 'REG1777480505208', 1, 1, 1, 1, NULL, '2026-05-01', '09:00', 5, 20.00, 2, '2026-04-30 00:38:45', NULL, '2026-04-30 00:35:05', '2026-04-30 00:38:45', '5'),
(36, 'REG1777481044364', 1, 1, 1, 1, NULL, '2026-05-02', '13:30', 3, 20.00, 2, '2026-04-30 00:44:18', NULL, '2026-04-30 00:44:04', '2026-04-30 00:44:18', '123123213'),
(37, 'REG1777481090050', 1, 1, 1, 1, NULL, '2026-05-01', '09:00', 6, 20.00, 2, '2026-04-30 00:44:59', NULL, '2026-04-30 00:44:50', '2026-04-30 00:44:59', '123213'),
(38, 'REG1777481199982', 2, 1, 1, 1, NULL, '2026-05-02', '09:00', 4, 20.00, 2, '2026-04-30 00:46:51', NULL, '2026-04-30 00:46:39', '2026-04-30 00:46:51', '123213'),
(39, 'REG1777481322694', 1, 1, 1, 1, NULL, '2026-05-01', '09:00', 7, 20.00, 2, '2026-04-30 00:48:54', NULL, '2026-04-30 00:48:42', '2026-04-30 00:48:54', '12414124'),
(40, 'REG1777481368917', 1, 1, 1, 1, NULL, '2026-05-01', '09:00', 8, 20.00, 2, '2026-04-30 02:03:10', NULL, '2026-04-30 00:49:28', '2026-04-30 02:03:10', '243525'),
(41, 'REG1777485756686', 1, 1, 1, 1, NULL, '2026-05-01', '09:00', 9, 20.00, 2, '2026-04-30 02:06:59', NULL, '2026-04-30 02:02:36', '2026-04-30 02:06:59', '214241'),
(42, 'REG1777485988266', 1, 1, 1, 1, NULL, '2026-04-30', '09:00', 6, 20.00, 2, '2026-04-30 02:06:57', NULL, '2026-04-30 02:06:28', '2026-04-30 02:06:57', '52525'),
(43, 'REG1777486002465', 4, 1, 1, 1, NULL, '2026-05-01', '09:00', 10, 20.00, 2, '2026-04-30 02:07:02', NULL, '2026-04-30 02:06:42', '2026-04-30 02:07:02', '124214214'),
(44, 'REG1777486318215', 1, 3, 3, 3, NULL, '2026-05-01', '09:00', 1, 18.00, 1, NULL, NULL, '2026-04-30 02:11:58', '2026-04-30 02:11:58', NULL),
(45, 'REG1777486465206', 1, 3, 3, 3, NULL, '2026-05-01', '09:30', 2, 18.00, 1, NULL, NULL, '2026-04-30 02:14:25', '2026-04-30 02:14:25', NULL),
(46, 'REG1777486815033', 2, 1, 1, 1, NULL, '2026-05-02', '09:00', 5, 20.00, 2, '2026-04-30 02:34:10', NULL, '2026-04-30 02:20:15', '2026-04-30 02:34:10', 'jaskldjsad'),
(47, 'REG1777486832643', 3, 1, 1, 1, NULL, '2026-05-02', '09:00', 6, 20.00, 2, '2026-04-30 02:56:54', NULL, '2026-04-30 02:20:32', '2026-04-30 02:56:54', '23532532'),
(48, 'REG1777486889075', 2, 1, 1, 1, NULL, '2026-05-02', '09:00', 7, 20.00, 2, '2026-04-30 03:15:15', NULL, '2026-04-30 02:21:29', '2026-04-30 03:15:15', '455'),
(49, 'REG1777486918873', 1, 1, 1, 1, NULL, '2026-05-02', '09:00', 8, 20.00, 1, NULL, NULL, '2026-04-30 02:21:58', '2026-04-30 02:21:58', NULL),
(50, 'REG1777486925505', 1, 1, 1, 1, NULL, '2026-05-02', '09:00', 9, 20.00, 1, NULL, NULL, '2026-04-30 02:22:05', '2026-04-30 02:22:05', NULL);

-- --------------------------------------------------------

--
-- 資料表結構 `schedule`
--

CREATE TABLE `schedule` (
  `id` bigint(20) NOT NULL COMMENT 'Schedule ID',
  `doctor_id` bigint(20) NOT NULL COMMENT 'Doctor ID',
  `department_id` bigint(20) NOT NULL COMMENT 'Department ID',
  `clinic_id` bigint(20) NOT NULL,
  `schedule_date` date NOT NULL COMMENT 'Schedule Date',
  `week_day` tinyint(4) NOT NULL COMMENT 'Week Day: 1-7',
  `time_slot` tinyint(4) NOT NULL COMMENT 'Time Slot: 1=morning, 2=afternoon, 3=evening',
  `max_count` int(11) NOT NULL DEFAULT 20 COMMENT 'Maximum Registration Count',
  `booked_count` int(11) NOT NULL DEFAULT 0 COMMENT 'Booked Count',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT 'Status: 1=open, 0=closed',
  `create_time` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Create Time',
  `update_time` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Update Time'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Doctor Schedule Table';

--
-- 傾印資料表的資料 `schedule`
--

INSERT INTO `schedule` (`id`, `doctor_id`, `department_id`, `clinic_id`, `schedule_date`, `week_day`, `time_slot`, `max_count`, `booked_count`, `status`, `create_time`, `update_time`) VALUES
(1, 1, 1, 1, '2026-03-31', 2, 1, 20, 2, 1, '2026-04-02 23:04:55', '2026-04-06 19:09:35'),
(2, 2, 2, 1, '2026-03-31', 2, 1, 20, 5, 1, '2026-04-02 23:04:55', '2026-04-05 19:46:54'),
(3, 3, 3, 1, '2026-03-31', 2, 2, 15, 2, 1, '2026-04-02 23:04:55', '2026-04-05 19:46:54'),
(4, 4, 4, 1, '2026-03-31', 2, 2, 18, 1, 1, '2026-04-02 23:04:55', '2026-04-05 19:46:54'),
(7, 1, 1, 1, '2026-04-28', 3, 1, 20, 1, 1, '2026-04-26 02:10:16', '2026-04-26 03:31:15'),
(8, 1, 1, 1, '2026-04-28', 3, 2, 20, 0, 1, '2026-04-26 02:10:16', '2026-04-26 03:30:39'),
(9, 1, 1, 1, '2026-04-28', 3, 3, 20, 0, 1, '2026-04-26 02:10:16', '2026-04-26 03:31:05'),
(10, 2, 2, 2, '2026-04-28', 3, 1, 20, 0, 1, '2026-04-26 02:10:16', '2026-04-26 02:10:16'),
(11, 2, 2, 2, '2026-04-28', 3, 2, 20, 0, 1, '2026-04-26 02:10:16', '2026-04-26 02:10:16'),
(12, 2, 2, 2, '2026-04-28', 3, 3, 20, 0, 1, '2026-04-26 02:10:16', '2026-04-26 02:10:16'),
(13, 3, 3, 3, '2026-04-28', 3, 1, 20, 0, 1, '2026-04-26 02:10:16', '2026-04-26 02:10:16'),
(14, 3, 3, 3, '2026-04-28', 3, 2, 20, 0, 1, '2026-04-26 02:10:16', '2026-04-26 02:10:16'),
(15, 3, 3, 3, '2026-04-28', 3, 3, 20, 0, 1, '2026-04-26 02:10:16', '2026-04-26 02:10:16'),
(16, 4, 4, 4, '2026-04-28', 3, 1, 20, 0, 1, '2026-04-26 02:10:16', '2026-04-26 02:10:16'),
(17, 4, 4, 4, '2026-04-28', 3, 2, 20, 0, 1, '2026-04-26 02:10:16', '2026-04-26 02:10:16'),
(18, 4, 4, 4, '2026-04-28', 3, 3, 20, 0, 1, '2026-04-26 02:10:16', '2026-04-26 02:10:16');

-- --------------------------------------------------------

--
-- 資料表結構 `system_setting`
--

CREATE TABLE `system_setting` (
  `setting_key` varchar(50) NOT NULL,
  `setting_value` varchar(255) NOT NULL,
  `description` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- 傾印資料表的資料 `system_setting`
--

INSERT INTO `system_setting` (`setting_key`, `setting_value`, `description`) VALUES
('booking_approval_required', '0', 'booking_approval_required'),
('cancel_deadline_hours', '24', 'cancel_deadline_hours'),
('max_active_bookings', '3', 'Max Active Bookings per Patient'),
('max_active_bookings_per_patient', '10', 'max_active_bookings_per_patient'),
('same_day_queue_enabled', '1', 'same_day_queue_enabled'),
('walkin_enabled_clinics', '5,1,4', 'walkin_enabled_clinics');

-- --------------------------------------------------------

--
-- 資料表結構 `user_notification`
--

CREATE TABLE `user_notification` (
  `id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `user_type` tinyint(4) NOT NULL COMMENT '1=admin, 2=doctor, 3=patient',
  `title` varchar(100) NOT NULL,
  `message` text NOT NULL,
  `type` varchar(20) DEFAULT 'info' COMMENT 'success, warning, info',
  `is_read` tinyint(1) DEFAULT 0,
  `create_time` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- 傾印資料表的資料 `user_notification`
--

INSERT INTO `user_notification` (`id`, `user_id`, `user_type`, `title`, `message`, `type`, `is_read`, `create_time`) VALUES
(7, 1, 3, 'Joined Walk-in Queue', 'You joined the walk-in queue: Q20260428001', 'success', 0, '2026-04-28 20:06:09'),
(8, 1, 3, 'Booking Confirmed', 'Your booking REG1777445518110 on 2026-05-01 has been confirmed.', 'success', 0, '2026-04-29 14:51:58'),
(9, 1, 3, 'Booking Confirmed', 'Your booking REG1777458576519 on 2026-04-30 has been confirmed.', 'success', 0, '2026-04-29 18:29:36'),
(10, 1, 3, 'Appointment Cancelled', 'Your appointment has been cancelled successfully.', 'warning', 0, '2026-04-29 21:03:26'),
(11, 1, 3, 'Appointment Cancelled', 'Your appointment has been cancelled successfully.', 'warning', 0, '2026-04-29 21:04:01'),
(12, 1, 3, 'Booking Confirmed', 'Your booking REG1777467864831 on 2026-05-07 has been confirmed.', 'success', 0, '2026-04-29 21:04:24'),
(13, 1, 3, 'Appointment Cancelled', 'Your appointment has been cancelled successfully.', 'warning', 0, '2026-04-29 21:04:30'),
(14, 1, 3, 'Booking Confirmed', 'Your booking REG1777468216807 on 2026-05-01 has been confirmed.', 'success', 0, '2026-04-29 21:10:16'),
(15, 1, 3, 'Appointment Cancelled', 'Your appointment has been cancelled successfully.', 'warning', 0, '2026-04-29 21:10:32'),
(16, 1, 3, 'Booking Confirmed', 'Your booking REG1777468489006 on 2026-04-30 has been confirmed.', 'success', 0, '2026-04-29 21:14:49'),
(17, 1, 3, 'Appointment Approved', 'Your appointment has been approved.', 'success', 0, '2026-04-29 21:15:48'),
(18, 1, 3, 'Joined Walk-in Queue', 'You joined the walk-in queue: Q20260429001', 'success', 0, '2026-04-29 21:17:18'),
(19, 1, 3, 'Booking Confirmed', 'Your booking REG1777468863945 on 2026-04-30 has been confirmed.', 'success', 0, '2026-04-29 21:21:03'),
(20, 1, 3, 'Joined Walk-in Queue', 'You joined the walk-in queue: Q20260429001', 'success', 0, '2026-04-29 21:38:59'),
(21, 1, 3, 'Please enter', 'It is your turn for consultation.', 'info', 0, '2026-04-29 21:49:49'),
(22, 1, 3, 'Joined Walk-in Queue', 'You joined the walk-in queue: Q20260429002', 'success', 0, '2026-04-29 21:58:15'),
(23, 2, 3, 'Joined Walk-in Queue', 'You joined the walk-in queue: Q20260429003', 'success', 0, '2026-04-29 21:58:32'),
(24, 1, 3, 'Please enter', 'It is your turn for consultation.', 'info', 0, '2026-04-29 22:16:00'),
(25, 2, 3, 'Please enter', 'It is your turn for consultation.', 'info', 0, '2026-04-29 22:16:00'),
(26, 1, 3, 'Booking Confirmed', 'Your booking REG1777472462666 on 2026-04-30 has been confirmed.', 'success', 0, '2026-04-29 22:21:02'),
(27, 1, 3, 'Appointment Rejected', 'Your appointment has been rejected.', 'warning', 0, '2026-04-29 22:21:26'),
(28, 2, 3, 'Joined Walk-in Queue', 'You joined the walk-in queue: Q20260429004', 'success', 0, '2026-04-29 22:23:35'),
(29, 2, 3, 'Booking Confirmed', 'Your booking REG1777472637148 on 2026-04-30 has been confirmed.', 'success', 0, '2026-04-29 22:23:57'),
(30, 2, 3, 'Booking Confirmed', 'Your booking REG1777472642543 on 2026-04-30 has been confirmed.', 'success', 0, '2026-04-29 22:24:02'),
(31, 1, 3, 'Booking Confirmed', 'Your booking REG1777472970548 on 2026-05-01 has been confirmed.', 'success', 0, '2026-04-29 22:29:30'),
(32, 2, 3, 'Appointment Rejected', 'Your appointment has been rejected.', 'warning', 0, '2026-04-29 22:29:50'),
(33, 2, 3, 'Appointment Rejected', 'Your appointment has been rejected.', 'warning', 0, '2026-04-29 22:29:54'),
(34, 2, 3, 'Appointment Rejected', 'Your appointment has been rejected.', 'warning', 0, '2026-04-29 22:29:58'),
(35, 2, 3, 'Appointment Rejected', 'Your appointment has been rejected.', 'warning', 0, '2026-04-29 22:37:14'),
(36, 2, 3, 'Appointment Rejected', 'Your appointment has been rejected.', 'warning', 0, '2026-04-29 22:37:23'),
(37, 1, 3, 'Appointment Cancelled', 'Your appointment has been cancelled. Reason: 123', 'warning', 0, '2026-04-29 22:47:07'),
(38, 1, 3, 'Booking Confirmed', 'Your booking REG1777475408438 on 2026-04-29 has been confirmed.', 'success', 0, '2026-04-29 23:10:08'),
(39, 1, 3, 'Booking Confirmed', 'Your booking REG1777475414843 on 2026-05-01 has been confirmed.', 'success', 0, '2026-04-29 23:10:14'),
(40, 1, 3, 'Appointment Cancelled', 'Your appointment has been cancelled successfully.', 'warning', 0, '2026-04-29 23:10:43'),
(41, 1, 3, 'Appointment Cancelled', 'Your appointment has been cancelled. Reason: 123', 'warning', 0, '2026-04-29 23:11:53'),
(42, 1, 3, 'Booking Confirmed', 'Your booking REG1777475916450 on 2026-04-29 has been confirmed.', 'success', 0, '2026-04-29 23:18:36'),
(43, 1, 3, 'Appointment Cancelled', 'Your appointment has been cancelled. Reason: 8', 'warning', 0, '2026-04-29 23:18:50'),
(44, 1, 3, 'Appointment Cancelled', 'Your appointment has been cancelled successfully.', 'warning', 0, '2026-04-29 23:19:30'),
(45, 1, 3, 'Booking Confirmed', 'Your booking REG1777476098328 on 2026-04-29 has been confirmed.', 'success', 0, '2026-04-29 23:21:38'),
(46, 1, 3, 'Appointment Cancelled', 'Your appointment has been cancelled successfully.', 'warning', 0, '2026-04-29 23:21:42'),
(47, 1, 3, 'Booking Confirmed', 'Your booking REG1777476180064 on 2026-04-29 has been confirmed.', 'success', 0, '2026-04-29 23:23:00'),
(48, 1, 3, 'Appointment Cancelled', 'Your appointment has been cancelled. Reason: 12321312', 'warning', 0, '2026-04-29 23:23:13'),
(49, 2, 3, 'Please enter', 'It is your turn for consultation.', 'info', 0, '2026-04-29 23:24:22'),
(50, 1, 3, 'Booking Confirmed', 'Your booking REG1777476419343 on 2026-04-29 has been confirmed.', 'success', 0, '2026-04-29 23:26:59'),
(51, 1, 3, 'Appointment Cancelled', 'Your appointment has been cancelled successfully.', 'warning', 0, '2026-04-29 23:27:04'),
(52, 1, 3, 'Booking Confirmed', 'Your booking REG1777477518204 on 2026-04-29 has been confirmed.', 'success', 0, '2026-04-29 23:45:18'),
(53, 1, 3, 'Appointment Cancelled', 'Your appointment has been cancelled successfully.', 'warning', 0, '2026-04-29 23:45:21'),
(54, 1, 3, 'Booking Confirmed', 'Your booking REG1777478014665 on 2026-04-29 has been confirmed.', 'success', 0, '2026-04-29 23:53:34'),
(55, 1, 3, 'Appointment Cancelled', 'Your appointment has been cancelled successfully.', 'warning', 0, '2026-04-30 00:00:40'),
(56, 1, 3, 'Booking Confirmed', 'Your booking REG1777478450595 on 2026-04-29 has been confirmed.', 'success', 0, '2026-04-30 00:00:50'),
(57, 1, 3, 'Booking Confirmed', 'Your booking REG1777478507611 on 2026-04-29 has been confirmed.', 'success', 0, '2026-04-30 00:01:47'),
(58, 1, 3, 'Booking Confirmed', 'Your booking REG1777478556550 on 2026-04-29 has been confirmed.', 'success', 0, '2026-04-30 00:02:36'),
(59, 1, 3, 'Booking Confirmed', 'Your booking REG1777478776533 on 2026-05-02 has been confirmed.', 'success', 0, '2026-04-30 00:06:16'),
(60, 1, 3, 'Appointment Cancelled', 'Your appointment has been cancelled. Reason: 1241234', 'warning', 0, '2026-04-30 00:10:03'),
(61, 1, 3, 'Appointment Cancelled', 'Your appointment has been cancelled successfully.', 'warning', 0, '2026-04-30 00:16:45'),
(62, 1, 3, 'Appointment Cancelled', 'Your appointment has been cancelled successfully.', 'warning', 0, '2026-04-30 00:16:54'),
(63, 1, 3, 'Appointment Cancelled', 'Your appointment has been cancelled successfully.', 'warning', 0, '2026-04-30 00:16:56'),
(64, 1, 3, 'Booking Confirmed', 'Your booking REG1777479438733 on 2026-05-02 has been confirmed.', 'success', 0, '2026-04-30 00:17:18'),
(65, 1, 3, 'Appointment Cancelled', 'Your appointment has been cancelled. Reason: 1232131', 'warning', 0, '2026-04-30 00:30:36'),
(66, 1, 3, 'Appointment Cancelled', 'Your appointment has been cancelled. Reason: 1232132131', 'warning', 0, '2026-04-30 00:30:38'),
(67, 1, 3, 'Booking Confirmed', 'Your booking REG1777480505208 on 2026-05-01 has been confirmed.', 'success', 0, '2026-04-30 00:35:05'),
(68, 1, 3, 'Appointment Cancelled', 'Your appointment has been cancelled. Reason: 5', 'warning', 0, '2026-04-30 00:38:45'),
(69, 1, 3, 'Booking Confirmed', 'Your booking REG1777481044364 on 2026-05-02 has been confirmed.', 'success', 0, '2026-04-30 00:44:04'),
(70, 1, 3, 'Appointment Cancelled', 'Your appointment has been cancelled. Reason: 123123213', 'warning', 0, '2026-04-30 00:44:18'),
(71, 1, 3, 'Booking Confirmed', 'Your booking REG1777481090050 on 2026-05-01 has been confirmed.', 'success', 0, '2026-04-30 00:44:50'),
(72, 1, 3, 'Appointment Cancelled', 'Your appointment has been cancelled. Reason: 123213', 'warning', 0, '2026-04-30 00:44:59'),
(73, 2, 3, 'Booking Confirmed', 'Your booking REG1777481199982 on 2026-05-02 has been confirmed.', 'success', 0, '2026-04-30 00:46:39'),
(74, 2, 3, 'Appointment Cancelled', 'Your appointment has been cancelled. Reason: 123213', 'warning', 0, '2026-04-30 00:46:51'),
(75, 1, 3, 'Booking Confirmed', 'Your booking REG1777481322694 on 2026-05-01 has been confirmed.', 'success', 0, '2026-04-30 00:48:42'),
(76, 1, 3, 'Appointment Cancelled', 'Your appointment has been cancelled. Reason: 12414124', 'warning', 0, '2026-04-30 00:48:54'),
(77, 1, 3, 'Joined Walk-in Queue', 'You joined the walk-in queue: Q20260430001', 'success', 0, '2026-04-30 00:49:22'),
(78, 1, 3, 'Booking Confirmed', 'Your booking REG1777481368917 on 2026-05-01 has been confirmed.', 'success', 0, '2026-04-30 00:49:28'),
(79, 1, 3, 'Booking Confirmed', 'Your booking REG1777485756686 on 2026-05-01 has been confirmed.', 'success', 0, '2026-04-30 02:02:36'),
(80, 1, 3, 'Appointment Cancelled', 'Your appointment has been cancelled. Reason: 243525', 'warning', 0, '2026-04-30 02:03:10'),
(81, 1, 3, 'Booking Confirmed', 'Your booking REG1777485988266 on 2026-04-30 has been confirmed.', 'success', 0, '2026-04-30 02:06:28'),
(82, 4, 3, 'Booking Confirmed', 'Your booking REG1777486002465 on 2026-05-01 has been confirmed.', 'success', 0, '2026-04-30 02:06:42'),
(83, 1, 3, 'Appointment Cancelled', 'Your appointment has been cancelled. Reason: 52525', 'warning', 0, '2026-04-30 02:06:57'),
(84, 1, 3, 'Appointment Cancelled', 'Your appointment has been cancelled. Reason: 214241', 'warning', 0, '2026-04-30 02:06:59'),
(85, 4, 3, 'Appointment Cancelled', 'Your appointment has been cancelled. Reason: 124214214', 'warning', 0, '2026-04-30 02:07:02'),
(86, 1, 3, 'Booking Confirmed', 'Your booking REG1777486318215 on 2026-05-01 has been confirmed.', 'success', 0, '2026-04-30 02:11:58'),
(87, 1, 3, 'Booking Confirmed', 'Your booking REG1777486465206 on 2026-05-01 has been confirmed.', 'success', 0, '2026-04-30 02:14:25'),
(88, 2, 3, 'Booking Confirmed', 'Your booking REG1777486815033 on 2026-05-02 has been confirmed.', 'success', 0, '2026-04-30 02:20:15'),
(89, 3, 3, 'Booking Confirmed', 'Your booking REG1777486832643 on 2026-05-02 has been confirmed.', 'success', 0, '2026-04-30 02:20:32'),
(90, 2, 3, 'Booking Confirmed', 'Your booking REG1777486889075 on 2026-05-02 has been confirmed.', 'success', 0, '2026-04-30 02:21:29'),
(91, 1, 3, 'Booking Confirmed', 'Your booking REG1777486918873 on 2026-05-02 has been confirmed.', 'success', 0, '2026-04-30 02:21:58'),
(92, 1, 3, 'Booking Confirmed', 'Your booking REG1777486925505 on 2026-05-02 has been confirmed.', 'success', 0, '2026-04-30 02:22:05'),
(93, 2, 3, 'Appointment Cancelled', 'Your appointment has been cancelled. Reason: jaskldjsad', 'warning', 0, '2026-04-30 02:34:10'),
(94, 1, 3, 'Please enter', 'It is your turn for consultation.', 'info', 0, '2026-04-30 02:37:07'),
(95, 1, 3, 'Joined Walk-in Queue', 'You joined the walk-in queue: Q20260430002', 'success', 0, '2026-04-30 02:37:24'),
(96, 1, 3, 'Please enter', 'It is your turn for consultation.', 'info', 0, '2026-04-30 02:37:43'),
(97, 3, 3, 'Appointment Cancelled', 'Your appointment has been cancelled. Reason: 23532532', 'warning', 0, '2026-04-30 02:56:54'),
(98, 2, 2, 'Test Alert', 'This is a test message', 'warning', 1, '2026-04-30 03:02:04'),
(99, 2, 3, 'Appointment Cancelled', 'Your appointment has been cancelled. Reason: 455', 'warning', 0, '2026-04-30 03:15:15'),
(100, 1, 2, 'High no-show warning', 'You have 33 patient no-show records. Please pay attention.', 'warning', 0, '2026-04-30 03:17:45');

--
-- 已傾印資料表的索引
--

--
-- 資料表索引 `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- 資料表索引 `clinic`
--
ALTER TABLE `clinic`
  ADD PRIMARY KEY (`id`);

--
-- 資料表索引 `clinic_time_slot`
--
ALTER TABLE `clinic_time_slot`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_clinic_period_time` (`clinic_id`,`period`,`slot_time`),
  ADD KEY `fk_clinic_time_slot_clinic` (`clinic_id`);

--
-- 資料表索引 `consultation`
--
ALTER TABLE `consultation`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `registration_id` (`registration_id`),
  ADD KEY `fk_consultation_patient` (`patient_id`),
  ADD KEY `fk_consultation_doctor` (`doctor_id`);

--
-- 資料表索引 `department`
--
ALTER TABLE `department`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `dept_name` (`dept_name`),
  ADD UNIQUE KEY `dept_code` (`dept_code`);

--
-- 資料表索引 `doctor`
--
ALTER TABLE `doctor`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD KEY `fk_doctor_department` (`department_id`),
  ADD KEY `primary_clinic_id` (`primary_clinic_id`),
  ADD KEY `fk_doctor_clinic` (`clinic_id`);

--
-- 資料表索引 `doctor_attendance`
--
ALTER TABLE `doctor_attendance`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_doctor_date` (`doctor_id`,`date`);

--
-- 資料表索引 `doctor_issue`
--
ALTER TABLE `doctor_issue`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_doctor_issue_doctor` (`doctor_id`);

--
-- 資料表索引 `hospitalization`
--
ALTER TABLE `hospitalization`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `admission_no` (`admission_no`),
  ADD KEY `fk_hospitalization_patient` (`patient_id`),
  ADD KEY `fk_hospitalization_doctor` (`doctor_id`),
  ADD KEY `fk_hospitalization_registration` (`registration_id`);

--
-- 資料表索引 `notice`
--
ALTER TABLE `notice`
  ADD PRIMARY KEY (`id`);

--
-- 資料表索引 `operation_log`
--
ALTER TABLE `operation_log`
  ADD PRIMARY KEY (`id`);

--
-- 資料表索引 `patient`
--
ALTER TABLE `patient`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `id_card` (`id_card`);

--
-- 資料表索引 `patient_favorite_clinic`
--
ALTER TABLE `patient_favorite_clinic`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_patient_favorite_patient` (`patient_id`),
  ADD KEY `fk_favorite_clinic` (`clinic_id`);

--
-- 資料表索引 `queue`
--
ALTER TABLE `queue`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_queue_patient` (`patient_id`),
  ADD KEY `fk_queue_doctor` (`doctor_id`),
  ADD KEY `fk_queue_clinic` (`clinic_id`);

--
-- 資料表索引 `recharge_record`
--
ALTER TABLE `recharge_record`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `recharge_no` (`recharge_no`),
  ADD KEY `fk_recharge_patient` (`patient_id`);

--
-- 資料表索引 `registration`
--
ALTER TABLE `registration`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `reg_no` (`reg_no`),
  ADD KEY `fk_registration_patient` (`patient_id`),
  ADD KEY `fk_registration_doctor` (`doctor_id`),
  ADD KEY `fk_registration_department` (`department_id`),
  ADD KEY `fk_registration_schedule` (`schedule_id`),
  ADD KEY `fk_registration_clinic` (`clinic_id`);

--
-- 資料表索引 `schedule`
--
ALTER TABLE `schedule`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_schedule_doctor` (`doctor_id`),
  ADD KEY `fk_schedule_department` (`department_id`),
  ADD KEY `fk_schedule_clinic` (`clinic_id`);

--
-- 資料表索引 `system_setting`
--
ALTER TABLE `system_setting`
  ADD PRIMARY KEY (`setting_key`);

--
-- 資料表索引 `user_notification`
--
ALTER TABLE `user_notification`
  ADD PRIMARY KEY (`id`);

--
-- 在傾印的資料表使用自動遞增(AUTO_INCREMENT)
--

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `admin`
--
ALTER TABLE `admin`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'Admin ID', AUTO_INCREMENT=3;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `clinic`
--
ALTER TABLE `clinic`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'Clinic ID', AUTO_INCREMENT=6;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `clinic_time_slot`
--
ALTER TABLE `clinic_time_slot`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'Time Slot ID', AUTO_INCREMENT=145;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `consultation`
--
ALTER TABLE `consultation`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'Consultation ID', AUTO_INCREMENT=3;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `department`
--
ALTER TABLE `department`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'Department ID', AUTO_INCREMENT=7;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `doctor`
--
ALTER TABLE `doctor`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'Doctor ID', AUTO_INCREMENT=8;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `doctor_attendance`
--
ALTER TABLE `doctor_attendance`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'Attendance ID', AUTO_INCREMENT=8;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `doctor_issue`
--
ALTER TABLE `doctor_issue`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'Issue ID', AUTO_INCREMENT=24;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `hospitalization`
--
ALTER TABLE `hospitalization`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'Hospitalization ID', AUTO_INCREMENT=3;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `notice`
--
ALTER TABLE `notice`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'Notice ID', AUTO_INCREMENT=4;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `operation_log`
--
ALTER TABLE `operation_log`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'Operation Log ID', AUTO_INCREMENT=6;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `patient`
--
ALTER TABLE `patient`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'Patient ID', AUTO_INCREMENT=6;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `patient_favorite_clinic`
--
ALTER TABLE `patient_favorite_clinic`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `queue`
--
ALTER TABLE `queue`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'Queue ID', AUTO_INCREMENT=12;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `recharge_record`
--
ALTER TABLE `recharge_record`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'Recharge Record ID', AUTO_INCREMENT=6;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `registration`
--
ALTER TABLE `registration`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'Registration ID', AUTO_INCREMENT=51;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `schedule`
--
ALTER TABLE `schedule`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'Schedule ID', AUTO_INCREMENT=22;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `user_notification`
--
ALTER TABLE `user_notification`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- 已傾印資料表的限制式
--

--
-- 資料表的限制式 `clinic_time_slot`
--
ALTER TABLE `clinic_time_slot`
  ADD CONSTRAINT `fk_clinic_time_slot_clinic` FOREIGN KEY (`clinic_id`) REFERENCES `clinic` (`id`) ON DELETE CASCADE;

--
-- 資料表的限制式 `consultation`
--
ALTER TABLE `consultation`
  ADD CONSTRAINT `fk_consultation_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctor` (`id`),
  ADD CONSTRAINT `fk_consultation_patient` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`id`),
  ADD CONSTRAINT `fk_consultation_registration` FOREIGN KEY (`registration_id`) REFERENCES `registration` (`id`);

--
-- 資料表的限制式 `doctor`
--
ALTER TABLE `doctor`
  ADD CONSTRAINT `doctor_ibfk_1` FOREIGN KEY (`primary_clinic_id`) REFERENCES `clinic` (`id`),
  ADD CONSTRAINT `fk_doctor_clinic` FOREIGN KEY (`clinic_id`) REFERENCES `clinic` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_doctor_department` FOREIGN KEY (`department_id`) REFERENCES `department` (`id`);

--
-- 資料表的限制式 `doctor_attendance`
--
ALTER TABLE `doctor_attendance`
  ADD CONSTRAINT `fk_attendance_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctor` (`id`) ON DELETE CASCADE;

--
-- 資料表的限制式 `doctor_issue`
--
ALTER TABLE `doctor_issue`
  ADD CONSTRAINT `fk_doctor_issue_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctor` (`id`);

--
-- 資料表的限制式 `hospitalization`
--
ALTER TABLE `hospitalization`
  ADD CONSTRAINT `fk_hospitalization_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctor` (`id`),
  ADD CONSTRAINT `fk_hospitalization_patient` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`id`),
  ADD CONSTRAINT `fk_hospitalization_registration` FOREIGN KEY (`registration_id`) REFERENCES `registration` (`id`);

--
-- 資料表的限制式 `patient_favorite_clinic`
--
ALTER TABLE `patient_favorite_clinic`
  ADD CONSTRAINT `fk_favorite_clinic` FOREIGN KEY (`clinic_id`) REFERENCES `clinic` (`id`),
  ADD CONSTRAINT `fk_patient_favorite_patient` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`id`);

--
-- 資料表的限制式 `queue`
--
ALTER TABLE `queue`
  ADD CONSTRAINT `fk_queue_clinic` FOREIGN KEY (`clinic_id`) REFERENCES `clinic` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_queue_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctor` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_queue_patient` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`id`) ON DELETE CASCADE;

--
-- 資料表的限制式 `recharge_record`
--
ALTER TABLE `recharge_record`
  ADD CONSTRAINT `fk_recharge_patient` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`id`);

--
-- 資料表的限制式 `registration`
--
ALTER TABLE `registration`
  ADD CONSTRAINT `fk_registration_clinic` FOREIGN KEY (`clinic_id`) REFERENCES `clinic` (`id`),
  ADD CONSTRAINT `fk_registration_department` FOREIGN KEY (`department_id`) REFERENCES `department` (`id`),
  ADD CONSTRAINT `fk_registration_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctor` (`id`),
  ADD CONSTRAINT `fk_registration_patient` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`id`),
  ADD CONSTRAINT `fk_registration_schedule` FOREIGN KEY (`schedule_id`) REFERENCES `schedule` (`id`);

--
-- 資料表的限制式 `schedule`
--
ALTER TABLE `schedule`
  ADD CONSTRAINT `fk_schedule_clinic` FOREIGN KEY (`clinic_id`) REFERENCES `clinic` (`id`),
  ADD CONSTRAINT `fk_schedule_department` FOREIGN KEY (`department_id`) REFERENCES `department` (`id`),
  ADD CONSTRAINT `fk_schedule_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctor` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
