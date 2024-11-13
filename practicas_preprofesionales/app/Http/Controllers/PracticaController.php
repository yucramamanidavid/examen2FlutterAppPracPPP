<?php

namespace App\Http\Controllers;

use App\Models\Alumno;
use App\Models\Practica;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;

class PracticaController extends Controller
{
    // Obtener todas las prácticas con paginación y filtros
    public function index(Request $request)
    {
        try {
            $query = Practica::query();

            // Filtrar por título
            if ($request->has('titulo')) {
                $query->where('titulo', 'like', '%' . $request->input('titulo') . '%');
            }

            // Filtrar por empresa
            if ($request->has('empresa')) {
                $query->where('empresa', 'like', '%' . $request->input('empresa') . '%');
            }

            // Filtrar por estado
            if ($request->has('estado')) {
                $query->where('estado', $request->input('estado'));
            }

            // Paginación con filtros aplicados
            $practicas = $query->paginate(10);

            return response()->json($practicas, 200);
        } catch (\Exception $e) {
            \Log::error('Error al obtener las prácticas: ' . $e->getMessage());
            return response()->json(['error' => 'Error al obtener las prácticas'], 500);
        }
    }

    // Crear una nueva práctica con estado "pendiente" y asociado a un alumno
    public function store(Request $request)
    {
        // Validar los datos de entrada
        $validator = Validator::make($request->all(), [
            'titulo' => 'required|string|max:255',
            'descripcion' => 'required|string',
            'empresa' => 'required|string|max:255',
            'fecha_inicio' => 'sometimes|required|date',
            'fecha_fin' => 'sometimes|required|date|after_or_equal:fecha_inicio',
            'alumno_id' => 'required|exists:alumnos,id' // Validar que el alumno_id sea válido
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()], 422);
        }
        // Verificar si el alumno existe
        $alumno = Alumno::find($request->alumno_id);
        if (!$alumno) {
            return response()->json(['error' => 'Alumno no encontrado'], 404);
        }

        try {
            $data = $request->all();
            $data['estado'] = 'pendiente'; // Estado inicial como 'pendiente'
            $practica = Practica::create($data);
            return response()->json($practica, 201);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Error al crear la práctica', 'details' => $e->getMessage()], 500);
        }
    }

    // Obtener una práctica específica por su ID
    public function show($id)
    {
        $practica = Practica::find($id);

        if (!$practica) {
            return response()->json(['error' => 'Práctica no encontrada'], 404);
        }

        return response()->json($practica, 200);
    }

    // Actualizar una práctica específica (admin/tutor puede cambiar el estado)
    public function update(Request $request, $id)
    {
        // Validar los datos de entrada
        $validator = Validator::make($request->all(), [
            'titulo' => 'sometimes|required|string|max:255',
            'descripcion' => 'sometimes|required|string',
            'empresa' => 'sometimes|required|string|max:255',
            'fecha_inicio' => 'sometimes|required|date',
            'fecha_fin' => 'sometimes|required|date|after_or_equal:fecha_inicio',
            'estado' => 'in:pendiente,aprobado,rechazado', // Validar que el estado sea válido
            'alumno_id' => 'required|exists:alumnos,id' // Validar que el alumno_id sea válido
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()], 422);
        }

        $practica = Practica::find($id);

        if (!$practica) {
            return response()->json(['error' => 'Práctica no encontrada'], 404);
        }

        try {
            $practica->update($request->all());
            return response()->json($practica, 200);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Error al actualizar la práctica', 'details' => $e->getMessage()], 500);
        }
    }

    // Cargar evidencia para una práctica específica (solo para prácticas aprobadas)
    public function uploadEvidencia(Request $request, $id)
    {
        $practica = Practica::find($id);

        if (!$practica) {
            return response()->json(['error' => 'Práctica no encontrada'], 404);
        }

        // Verificar si la práctica está aprobada
        if ($practica->estado !== 'aprobado') {
            return response()->json(['error' => 'Solo se puede cargar evidencia para prácticas aprobadas'], 403);
        }

        if ($request->hasFile('evidencia')) {
            try {
                // Almacenar el archivo de evidencia
                $file = $request->file('evidencia');
                $path = $file->store('evidencias', 'public');

                // Actualizar la práctica con la ruta del archivo de evidencia
                $practica->evidencia_path = $path;
                $practica->save();

                return response()->json(['message' => 'Evidencia subida con éxito', 'path' => $path], 200);
            } catch (\Exception $e) {
                return response()->json(['error' => 'Error al subir la evidencia', 'details' => $e->getMessage()], 500);
            }
        }

        return response()->json(['error' => 'No se envió ningún archivo de evidencia'], 400);
    }

    // Eliminar una práctica específica
    public function destroy($id)
    {
        $practica = Practica::find($id);

        if (!$practica) {
            return response()->json(['error' => 'Práctica no encontrada'], 404);
        }

        try {
            $practica->delete();
            return response()->json(['message' => 'Práctica eliminada con éxito'], 200);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Error al eliminar la práctica', 'details' => $e->getMessage()], 500);
        }
    }

    // Obtener prácticas específicas para un alumno
    public function obtenerPracticasPorAlumno($alumnoId)
    {
        try {
            $practicas = Practica::where('alumno_id', $alumnoId)->get();
            return response()->json($practicas, 200);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Error al obtener las prácticas del alumno'], 500);
        }
    }
    // En PracticaController.php

public function aprobarPractica($id)
{
    $practica = Practica::find($id);

    if (!$practica) {
        return response()->json(['error' => 'Práctica no encontrada'], 404);
    }

    try {
        $practica->estado = 'aprobado';
        $practica->save();
        return response()->json(['message' => 'Práctica aprobada exitosamente'], 200);
    } catch (\Exception $e) {
        return response()->json(['error' => 'Error al aprobar la práctica', 'details' => $e->getMessage()], 500);
    }
}

public function rechazarPractica($id)
{
    $practica = Practica::find($id);

    if (!$practica) {
        return response()->json(['error' => 'Práctica no encontrada'], 404);
    }

    try {
        $practica->estado = 'rechazado';
        $practica->save();
        return response()->json(['message' => 'Práctica rechazada exitosamente'], 200);
    } catch (\Exception $e) {
        return response()->json(['error' => 'Error al rechazar la práctica', 'details' => $e->getMessage()], 500);
    }
}
public function obtenerPracticasPendientes()
{
    try {
        $practicas = Practica::where('estado', 'pendiente')->get();
        return response()->json($practicas, 200);
    } catch (\Exception $e) {
        return response()->json(['error' => 'Error al obtener prácticas pendientes', 'details' => $e->getMessage()], 500);
    }
}

public function cambiarEstadoPractica(Request $request, $id) {
    try {
        $practica = Practica::findOrFail($id);
        $estado = $request->input('estado'); // obtiene el estado desde la solicitud

        if (in_array($estado, ['aprobado', 'rechazado'])) {
            $practica->estado = $estado;
            $practica->save();
            return response()->json(['message' => 'Estado de la práctica actualizado con éxito']);
        } else {
            return response()->json(['error' => 'Estado no válido'], 422);
        }
    } catch (\Exception $e) {
        return response()->json(['error' => 'Error al cambiar el estado de la práctica', 'details' => $e->getMessage()], 500);
    }
}

// En PracticaController.php
public function obtenerEstadisticas() {
    try {
        $aprobadas = Practica::where('estado', 'aprobado')->count();
        $rechazadas = Practica::where('estado', 'rechazado')->count();
        $progreso = Practica::where('estado', 'aprobado')->avg('progreso'); // Ejemplo de progreso en %

        return response()->json([
            'aprobadas' => $aprobadas,
            'rechazadas' => $rechazadas,
            'progreso' => $progreso ?? 0,
        ], 200);
    } catch (\Exception $e) {
        return response()->json(['error' => 'Error al obtener estadísticas'], 500);
    }
}


}
