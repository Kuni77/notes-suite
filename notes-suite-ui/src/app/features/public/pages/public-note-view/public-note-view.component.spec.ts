import { ComponentFixture, TestBed } from '@angular/core/testing';

import { PublicNoteViewComponent } from './public-note-view.component';

describe('PublicNoteViewComponent', () => {
  let component: PublicNoteViewComponent;
  let fixture: ComponentFixture<PublicNoteViewComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [PublicNoteViewComponent]
    })
    .compileComponents();
    
    fixture = TestBed.createComponent(PublicNoteViewComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
