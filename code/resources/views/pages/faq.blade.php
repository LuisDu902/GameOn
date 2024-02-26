@extends('layouts.app')

@section('content')
    <x-sidebar></x-sidebar>

    <div class="headers">
        <button class="open-sidebar">
            <ion-icon name="menu"></ion-icon>
        </button>
        <ul class="breadcrumb">
            <li><a href="{{ route('home') }}">
                <ion-icon name="home-outline"></ion-icon> Home</a>
            </li>
            <li> Frequently Asked Questions</li>
        </ul>
    </div>
   
    <section class="faq-sec">
        <h1> Frequently Asked Questions</h1>
        <div class="faqs-grid">
            <div class="faqs-wrapper">
                <x-faqItem :title="'How do I become a certified user on GameOn?'" :content="'To become a certified user on GameOn, actively engage with the community by posting insightful content, providing valuable answers, and receiving positive peer votes on your contributions. As your contributions are recognized and appreciated by the community, you will progress through ranks, starting from Bronze, moving up to Gold, and achieving the esteemed Master status.'"></x-faqItem>
                <x-faqItem :title="'Can I edit or delete my posts on GameOn after submission?'" :content="'Yes, authenticated users have the ability to edit or delete their own posts, providing flexibility and control over their contributions to the platform.'"></x-faqItem>
                <x-faqItem :title="'How can I report inappropriate content or behavior on GameOn?'" :content="'Simply use the report function available on posts or user profiles to notify our moderation team. We take swift action against any content or behavior violating our community guidelines.'"></x-faqItem>
                <x-faqItem :title="'What kind of rewards or recognition do users receive for their contributions?'" :content="'Users who actively participate and contribute on GameOn receive recognition in the form of badges and ranks based on their contributions and peer feedback. These badges showcase expertise and commitment within the gaming community.'"></x-faqItem>
                <x-faqItem :title="'How can I contribute content to specific game sections or interests within GameOn?'" :content="'To contribute content to specific game sections or interests, navigate to the relevant section or use the advanced search feature to find the desired category. From there, you can post questions, share insights, or engage in discussions related to that particular game or interest area.'"></x-faqItem>
            </div>
            <div class="faqs-wrapper">
                <x-faqItem :title="'How are administrators chosen or selected?'" :content="'Administrators are selected based on a thorough vetting process by the existing administration team. They are chosen for their demonstrated commitment to the community, understanding of the platforms goals, and ability to responsibly manage platform activities.'"></x-faqItem>
                <x-faqItem :title="'Can users suggest new features or improvements for GameOn?'" :content="'Absolutely! We encourage users to share their ideas and suggestions for improving GameOn. You can submit your suggestions through our designated feedback channels or community forums, where they will be reviewed and considered by our development team.'"></x-faqItem>
                <x-faqItem :title="'Does GameOn support multiple languages for its interface?'" :content="'Currently, GameOn supports multiple languages, aiming to provide a more inclusive experience for users. We are continuously working to expand language options.'"></x-faqItem>
                <x-faqItem :title="'Is there a system in place to resolve disputes or issues within the community?'" :content="'Yes, GameOn has a dedicated support system to address conflicts or issues that may arise within the community. Users can report concerns, and our team will investigate and take appropriate actions to resolve disputes and maintain a positive atmosphere.'"></x-faqItem>
                <x-faqItem :title="'Are there any limitations to the types of content or discussions allowed on the platform?'" :content="'GameOn maintains a set of community guidelines to ensure a positive and safe environment for all users. Content that violates these guidelines, including offensive material or misinformation, may be removed to maintain the platforms integrity.'"></x-faqItem>
            </div>
        </div>
    </section>
@endsection
