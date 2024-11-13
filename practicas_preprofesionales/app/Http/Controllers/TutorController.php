<?php

namespace App\Http\Controllers;

use App\Models\Alumno;
use App\Models\Practica;
use App\Models\Tutor;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class TutorController extends Controller
{
    public function index()
    {
        $tutores = Tutor::all();
        return response()->json($tutores);
    }

    public function getAlumnosAsignados(Request $request)
    {
        $user = $request->user();
        if ($user->role !== 'tutor') {
            return response()->json(['error' => 'No autorizado'], 403);
        }

        $tutor = Tutor::where('user_id', $user->id)->first();
        if (!$tutor) {
            return response()->json(['error' => 'Tutor no encontrado'], 404);
        }

        $alumnos = $tutor->alumnos; // Asume que tienes una relación "alumnos" en el modelo Tutor
        return response()->json($alumnos);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nombre' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:tutors,email',
            'password' => 'required|string|min:8' // Validación del campo password
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()], 422);
        }

        $tutor = Tutor::create([
            'nombre' => $request->nombre,
            'email' => $request->email,
            'password' => bcrypt($request->password), // Hash de la contraseña
        ]);

        return response()->json(['message' => 'Tutor creado con éxito', 'tutor' => $tutor], 201);
    }

    public function update(Request $request, $id)
    {
        $tutor = Tutor::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'nombre' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:tutors,email,' . $tutor->id,
            'password' => 'nullable|string|min:8' // Permitir que la contraseña sea opcional al actualizar
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()], 422);
        }

        $tutor->nombre = $request->nombre;
        $tutor->email = $request->email;
        if ($request->filled('password')) {
            $tutor->password = bcrypt($request->password); // Actualizar contraseña solo si se envía
        }
        $tutor->save();

        return response()->json(['message' => 'Tutor actualizado con éxito', 'tutor' => $tutor], 200);
    }

    public function destroy($id)
    {
        $tutor = Tutor::findOrFail($id);
        $tutor->delete();

        return response()->json(['message' => 'Tutor eliminado con éxito'], 200);
    }

    public function obtenerAlumnosAsignados($tutorId)
    {
        try {
            $tutor = Tutor::findOrFail($tutorId);
            $alumnos = $tutor->alumnos; // Asume que tienes una relación 'alumnos' en el modelo Tutor
            return response()->json($alumnos, 200);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Error al obtener alumnos asignados', 'details' => $e->getMessage()], 500);
        }
    }

    public function obtenerPracticas($id)
    {
        $practicas = Practica::where('alumno_id', $id)->get();
        return response()->json($practicas);
    }
    public function asignarTutorAAlumnos(Request $request)
{
    $request->validate([
        'tutor_id' => 'required|exists:tutores,id',
        'alumno_ids' => 'required|array',
        'alumno_ids.*' => 'exists:alumnos,id',
    ]);

    $tutor = Tutor::findOrFail($request->tutor_id);
    $tutor->alumnos()->syncWithoutDetaching($request->alumno_ids);

    return response()->json(['message' => 'Tutor asignado a los alumnos con éxito'], 200);
}


public function obtenerAlumnosConTutores()
{
    $alumnos = Alumno::with('tutores')->get();

    $result = $alumnos->map(function ($alumno) {
        return [
            'alumno_id' => $alumno->id,
            'alumno_nombre' => $alumno->nombre,
            'tutores' => $alumno->tutores->map(function ($tutor) {
                return [
                    'tutor_id' => $tutor->id,
                    'tutor_nombre' => $tutor->nombre,
                ];
            }),
        ];
    });

    return response()->json($result);
}

public function obtenerTutoresConAlumnosAsignados()
{
    try {
        // Obtener todos los tutores y cargar los alumnos asignados en la relación
        $tutores = Tutor::with('alumnos')->get();

        // Formatear la respuesta para incluir tutores con sus respectivos alumnos
        $response = $tutores->map(function ($tutor) {
            return [
                'tutor' => [
                    'id' => $tutor->id,
                    'nombre' => $tutor->nombre,
                    'email' => $tutor->email,
                ],
                'alumnos' => $tutor->alumnos->map(function ($alumno) {
                    return [
                        'id' => $alumno->id,
                        'nombre' => $alumno->nombre,
                        'codigo' => $alumno->codigo,
                    ];
                }),
            ];
        });

        return response()->json($response, 200);
    } catch (\Exception $e) {
        return response()->json(['error' => 'Error al obtener tutores con alumnos asignados', 'details' => $e->getMessage()], 500);
    }
}
    public function obtenerPracticasPorAlumno($alumnoId)
{
    $practicas = Practica::where('alumno_id', $alumnoId)->get();
    return response()->json($practicas);
}

}
