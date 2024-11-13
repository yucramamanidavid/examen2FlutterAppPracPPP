<?php

namespace App\Http\Controllers;

use App\Models\Alumno;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AlumnoController extends Controller
{
    public function index(Request $request)
    {
        $query = $request->query('query');
        $alumnos = Alumno::when($query, function ($q) use ($query) {
            return $q->where('nombre', 'like', "%$query%")
                     ->orWhere('codigo', 'like', "%$query%");
        })->get();

        return response()->json($alumnos);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nombre' => 'required|string|max:255',
            'codigo' => 'required|string|unique:alumnos,codigo', // Código único
            'email' => 'required|string|email|max:255',
            'user_id' => 'required|exists:users,id', // Validar que el user_id sea válido y exista en la tabla users
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()], 422);
        }

        $alumno = Alumno::create($request->all());
        return response()->json(['message' => 'Alumno creado con éxito', 'alumno' => $alumno], 201);
    }

    public function update(Request $request, $id)
    {
        $alumno = Alumno::findOrFail($id);
        $request->validate([
            'nombre' => 'required|string|max:255',
            'codigo' => 'required|string|unique:alumnos,codigo,' . $alumno->id,
            'email' => 'required|string|email|max:255',
            'user_id' => 'sometimes|exists:users,id', // Validación opcional del user_id
        ]);

        $alumno->update($request->all());
        return response()->json(['message' => 'Alumno actualizado con éxito', 'alumno' => $alumno], 200);
    }

    public function destroy($id)
    {
        $alumno = Alumno::findOrFail($id);
        $alumno->delete();

        return response()->json(['message' => 'Alumno eliminado con éxito'], 200);
    }
}
