module CourseTracker::CourseTracker {
    use aptos_framework::signer;
    use aptos_framework::event::{Self, EventHandle, emit_event};

    struct CourseInfo<phantom T> has key {
        total_courses: u64,
        completed_courses: u64,
        completion_events: EventHandle<CompletionEvent<T>>,
    }

    struct CompletionEvent<phantom T> has drop, store {
        student: address,
        course_id: T,
    }

    public fun initialize_course<T: copy + drop + store>(
        admin: &signer,
        total_courses: u64,
    ) {
        let course_info = CourseInfo<T> {
            total_courses,
            completed_courses: 0,
            completion_events: new_event_handle<CompletionEvent<T>>(),
        };
        move_to(admin, course_info);
    }

    public fun complete_course<T: copy + drop + store>(
        student: &signer,
        course_id: T,
    ) acquires CourseInfo<T> {
        let course_info = borrow_global_mut<CourseInfo<T>>(signer::address_of(student));
        course_info.completed_courses += 1;
        emit_event<CompletionEvent<T>>(
            &mut course_info.completion_events,
            CompletionEvent { student: signer::address_of(student), course_id },
        );
    }
}