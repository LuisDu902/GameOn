@if ($questions->count() > 0)
    <ul class="questions">
        @foreach($questions as $question)
            <li class="question-card"  id="{{ $question->id }}">
                <div class="q-stats">
                    <span>{{ $question->votes }} votes</span>
                    @if ($question->is_solved)
                        <span class="solved-question"> <strong>✔{{ $question->answers->count() }} answers </strong></span>
                    @else
                        <span> {{ $question->answers->count() }} answers</span>
                    @endif
                    <span>{{ $question->nr_views }} views</span>
                </div>
                <div class="q-content">
                    <a href="{{ route('question', ['id' => $question->id]) }}">
                        <h2>{{ $question->title }}</h2>
                    </a>

                    @if (strlen($question->latestContent()) >= 300)
                        <p>{{ substr($question->latestContent(), 0, 300) }}...</p>
                    @else
                        <p>{{ $question->latestContent() }}</p>
                    @endif
                    <div class="q-lline">
                        <div class="q-ltags">
                            @foreach ($question->tags as $tag)
                             <span>{{ $tag->name }}</span>
                            @endforeach
                        </div>
                        <span><a href="{{ route('profile', ['id' => $question->creator->id ]) }}" class="purple">{{ $question->creator->username }}</a> asked {{ $question->timeDifference() }} ago</span>
                    </div>
                </div>
            </li>
        @endforeach
    </ul>
@else
    <div class="no-questions">
        <img class="no-questions-image" src="{{ asset('images/pikachuConfused.png') }}" alt="Psyduck Image">
        <p>No questions yet.</p>
    </div>
@endif