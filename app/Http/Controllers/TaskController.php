<?php

namespace App\Http\Controllers;

use App\Models\Task;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Validator;
use Illuminate\Routing\Controller;

class TaskController extends Controller
{
    public function index(Request $request)
    {
        $query = Task::query();

        if ($request->has('status') && in_array($request->status, Task::VALID_STATUSES)) {
            $query->where('status', $request->status);
        }

        if ($request->has('priority') && is_numeric($request->priority)) {
            $priority = (int) $request->priority;
            if ($priority >= 1 && $priority <= 5) {
                $query->where('priority', $priority);
            }
        }

        $validSortFields = ['priority', 'created_at', 'updated_at'];
        $sortField = in_array($request->sort, $validSortFields) ? $request->sort : 'created_at';

        $validOrderDirections = ['asc', 'desc'];
        $orderDirection = in_array(strtolower($request->order), $validOrderDirections) ? $request->order : 'desc';

        $query->orderBy($sortField, $orderDirection);

        $perPage = $request->has('per_page') ? (int) $request->per_page : 10;
        $perPage = max(1, min($perPage, 100));

        $tasks = $query->paginate($perPage);

        return response()->json([
            'data' => $tasks->items(),
            'meta' => [
                'current_page' => $tasks->currentPage(),
                'per_page' => $tasks->perPage(),
                'total' => $tasks->total(),
                'last_page' => $tasks->lastPage(),
            ]
        ]);
    }

    public function show($id)
    {
        $task = Task::find($id);

        if (!$task) {
            return response()->json([
                'error' => 'Task not found'
            ], Response::HTTP_NOT_FOUND);
        }

        return response()->json($task);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'title' => 'required|string|max:100',
            'description' => 'nullable|string',
            'status' => 'nullable|string|in:pending,running,completed,failed',
            'priority' => 'nullable|integer|min:1|max:5',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'error' => 'Validation failed',
                'details' => $validator->errors()
            ], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $task = Task::create([
            'title' => $request->title,
            'description' => $request->description ?? null,
            'status' => $request->status ?? 'pending',
            'priority' => $request->priority ?? 1,
        ]);

        return response()->json($task, Response::HTTP_CREATED);
    }

    public function update(Request $request, $id)
    {
        $task = Task::find($id);

        if (!$task) {
            return response()->json([
                'error' => 'Task not found'
            ], Response::HTTP_NOT_FOUND);
        }

        $validator = Validator::make($request->all(), [
            'title' => 'nullable|string|max:100',
            'description' => 'nullable|string',
            'status' => 'nullable|string|in:pending,running,completed,failed',
            'priority' => 'nullable|integer|min:1|max:5',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'error' => 'Validation failed',
                'details' => $validator->errors()
            ], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        if ($request->has('title')) {
            $task->title = $request->title;
        }
        if ($request->has('description')) {
            $task->description = $request->description;
        }
        if ($request->has('status')) {
            $task->status = $request->status;
        }
        if ($request->has('priority')) {
            $task->priority = $request->priority;
        }

        $task->save();

        return response()->json($task);
    }

    public function destroy($id)
    {
        $task = Task::find($id);

        if (!$task) {
            return response()->json([
                'error' => 'Task not found'
            ], Response::HTTP_NOT_FOUND);
        }

        $task->delete();

        return response()->json(null, Response::HTTP_NO_CONTENT);
    }

    public function complete($id)
    {
        $task = Task::find($id);

        if (!$task) {
            return response()->json([
                'error' => 'Task not found'
            ], Response::HTTP_NOT_FOUND);
        }

        $task->status = Task::STATUS_COMPLETED;
        $task->save();

        return response()->json($task);
    }
}