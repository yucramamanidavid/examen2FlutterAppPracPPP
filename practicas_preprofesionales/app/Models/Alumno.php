<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Alumno extends Model
{
    use HasFactory;

    protected $fillable = [
        'nombre',
        'codigo', // Código único para cada alumno
        'email',
        'user_id',
        'tutor_id', // ID del usuario asociado (si es necesario)
    ];

    // Relación con el usuario (opcional)
    public function user()
    {
        return $this->belongsTo(User::class);
    }
    public function tutores()
     {
         return $this->belongsToMany(Tutor::class, 'alumno_tutor', 'alumno_id', 'tutor_id');
     }
    // public function tutor()
    // {
    //     return $this->belongsTo(Tutor::class);
    // }

}
