<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Practica extends Model
{
    use HasFactory;

    // Campos que se pueden asignar masivamente
    protected $fillable = [
        'titulo',
        'descripcion',
        'empresa',
        'fecha_inicio',
        'fecha_fin',
        'estado',
        'alumno_id', // Nuevo campo
    ];
    // Valor por defecto para el campo 'estado'
    protected $attributes = [
        'estado' => 'pendiente',
    ];
    public function alumnos()
    {
        return $this->hasMany(Alumno::class);
    }
}
