<tr class="report-info" id="report{{ $report->id }}" data-id="{{ $report->id }}">
<td><img src="{{ $report->reported->getProfileImage() }}" alt="User Image"></td>    
<td><a href="{{ route('profile', ['id' => $report->reporter->id]) }}">{{ $report->reporter->name }}</td> <!-- assuming 'name' is the attribute -->
    <td><a href="{{ route('profile', ['id' => $report->reported->id]) }}">{{ $report->reported->name }}</td> <!-- replace 'name' with the actual attribute -->
    <td class="explanation-text"> {{ $report->explanation }}</td>
    <td id="reason">{{ $report->reason }}</td>
    <td>
        <select name="status" class="status-dropdown" data-report="{{ $report->id }}" onchange="changeReportStatus(this)">
            <option value="1" class="status-solved" {{ $report->is_solved ? 'selected' : '' }}>Solved</option>
            <option value="0" class="status-unsolved" {{ !$report->is_solved ? 'selected' : '' }}>Unsolved</option>
        </select>
    </td>


</tr>


