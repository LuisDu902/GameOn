@if ($paginator->hasPages())
    
<ul class="custom-pagination">
    @if (!$paginator->onFirstPage())  
        <a class="arrow" href="{{ $paginator->previousPageUrl() }}" rel="prev" aria-label="@lang('pagination.previous')">&lsaquo;</a>
    @endif

    @foreach ($elements as $element)
        @if (is_string($element))
            <li class="page-item disabled" aria-disabled="true"><span class="page-link">{{ $element }}</span></li>
        @endif

        @if (is_array($element))
            @foreach ($element as $page => $url)
                @if ($page == $paginator->currentPage())
                    <li class="page-item current" aria-current="page"><span class="page-link">{{ $page }}</span></li>
                @else
                    <a class="page-link" href="{{ $url }}"><li class="page-item">{{ $page }}</li></a>
                @endif
            @endforeach
        @endif
    @endforeach

    @if ($paginator->hasMorePages())
        <a class="arrow" href="{{ $paginator->nextPageUrl() }}" rel="next" aria-label="@lang('pagination.next')">&rsaquo;</a>
    @endif
</ul>
@endif
