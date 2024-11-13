<?php

use App\Http\Controllers\AlumnoController;
use App\Http\Controllers\AuthController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\PracticaController;
use App\Http\Controllers\TutorController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});
Route::get('/practicas', [PracticaController::class, 'index']);
Route::post('/practicas', [PracticaController::class, 'store']);
Route::get('/practicas/{id}', [PracticaController::class, 'show']);
Route::put('/practicas/{id}', [PracticaController::class, 'update']);
Route::delete('/practicas/{id}', [PracticaController::class, 'destroy']);
Route::put('/practicas/{id}', [PracticaController::class, 'update']);
Route::post('/practicas/{id}/evidencia', [PracticaController::class, 'uploadEvidencia']);
Route::get('/alumnos/{alumnoId}/practicas', [PracticaController::class, 'obtenerPracticasPorAlumno']);

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::middleware('auth:sanctum')->put('/profile', [AuthController::class, 'updateProfile']);
// Rutas para Alumno
Route::get('/alumnos', [AlumnoController::class, 'index']);
Route::post('/alumnos', [AlumnoController::class, 'store']);
Route::put('/alumnos/{id}', [AlumnoController::class, 'update']);
Route::delete('/alumnos/{id}', [AlumnoController::class, 'destroy']);

// Rutas para Tutor
Route::get('/tutores', [TutorController::class, 'index']);
Route::post('/tutores', [TutorController::class, 'store']);
Route::put('/tutores/{id}', [TutorController::class, 'update']);
Route::delete('/tutores/{id}', [TutorController::class, 'destroy']);
Route::middleware('auth:sanctum')->get('/tutor/alumnos', [TutorController::class, 'getAlumnosAsignados']);
// Rutas para obtener alumnos asignados al tutor
Route::get('/tutores/alumnos_asignados', [TutorController::class, 'obtenerAlumnosAsignados']);
Route::post('/tutor/asignar', [TutorController::class, 'asignarTutorAAlumnos']);
// Ruta para obtener las prácticas de un alumno específico
Route::get('/alumnos/{id}/practicas', [AlumnoController::class, 'obtenerPracticas']);
Route::get('/tutores/{tutorId}/alumnos', [TutorController::class, 'obtenerAlumnosAsignados']);
Route::get('/tutores-con-alumnos', [TutorController::class, 'obtenerTutoresConAlumnosAsignados']);
Route::get('alumnos/{alumnoId}/practicas', [PracticaController::class, 'obtenerPracticasPorAlumno']);
Route::get('/tutores-asignados', [TutorController::class, 'obtenerTutoresConAlumnosAsignados']);
Route::post('/practicas/{id}/cambiar-estado', [PracticaController::class, 'cambiarEstadoPractica']);
Route::put('/practicas/{id}/cambiar-estado', [PracticaController::class, 'cambiarEstadoPractica']);
Route::get('practicasPendientes', [PracticaController::class, 'obtenerPracticasPendientes']);
