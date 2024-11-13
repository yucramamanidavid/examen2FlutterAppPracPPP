<?php

namespace App\Http\Controllers;

use App\Models\Alumno;
use App\Models\Tutor;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        // Verifica que el usuario exista y que la contraseña sea correcta
        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json(['error' => 'Credenciales incorrectas'], 401);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        // Obtener el alumno_id o tutor_id si el usuario tiene uno de estos roles
        $alumnoId = null;
        $tutorId = null;

        if ($user->role === 'user') {
            $alumno = Alumno::where('user_id', $user->id)->first();
            $alumnoId = $alumno ? $alumno->id : null;
        } elseif ($user->role === 'tutor') {
            $tutor = Tutor::where('user_id', $user->id)->first();
            $tutorId = $tutor ? $tutor->id : null;
        }

        return response()->json([
            'access_token' => $token,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'role' => $user->role,
                'alumno_id' => $alumnoId,
                'tutor_id' => $tutorId,
            ],
        ], 200);
    }

    public function register(Request $request)
    {
        // Validar los datos de entrada
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:6',
            'role' => 'required|in:admin,user,tutor',
            'codigo' => 'nullable|string|unique:alumnos,codigo' // Código opcional y único para alumnos
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()], 422);
        }

        try {
            // Crear el usuario
            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'password' => Hash::make($request->password),
                'role' => $request->role,
            ]);

            // Crear registro adicional en la tabla correspondiente según el rol
            if ($request->role === 'user') {
                // Usar el código proporcionado o generar uno automáticamente
                $codigo = $request->codigo ?: $this->generarCodigoUnico();

                Alumno::create([
                    'nombre' => $request->name,
                    'email' => $request->email,
                    'codigo' => $codigo, // Código único
                    'user_id' => $user->id,
                ]);
            } elseif ($request->role === 'tutor') {
                // Verificar que no exista el tutor con el mismo email
                if (Tutor::where('email', $request->email)->exists()) {
                    throw new \Exception('El correo electrónico ya está registrado como tutor.');
                }

                Tutor::create([
                    'nombre' => $request->name,
                    'email' => $request->email,
                    'user_id' => $user->id,
                ]);
            }

            return response()->json(['message' => 'Usuario registrado con éxito'], 201);
        } catch (\Exception $e) {
            // Registrar el error en los logs y devolver un error 500
            \Log::error('Error al registrar el usuario: ' . $e->getMessage());
            return response()->json(['error' => 'Error interno del servidor', 'details' => $e->getMessage()], 500);
        }
    }

    private function generarCodigoUnico()
    {
        do {
            $codigo = date('Y') . rand(1000, 9999); // Genera un código en formato AÑO+NUMERO
        } while (Alumno::where('codigo', $codigo)->exists());

        return $codigo;
    }

    public function updateProfile(Request $request)
    {
        $user = $request->user();

        // Validación de los datos de entrada
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users,email,' . $user->id,
        ]);

        // Actualizar el perfil del usuario
        try {
            $user->update($request->only('name', 'email'));
            return response()->json(['message' => 'Perfil actualizado con éxito', 'user' => $user], 200);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Error al actualizar el perfil'], 500);
        }
    }
}
