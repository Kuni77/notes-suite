import { HttpInterceptorFn, HttpErrorResponse } from '@angular/common/http';
import { inject } from '@angular/core';
import { catchError, throwError } from 'rxjs';
import { AuthService } from '../services/auth.service';
import { ToastrService } from 'ngx-toastr';

export const errorInterceptor: HttpInterceptorFn = (req, next) => {
  const authService = inject(AuthService);
  const toastr = inject(ToastrService);

  return next(req).pipe(
    catchError((error: HttpErrorResponse) => {
      let errorMessage = 'An error occurred';
      console.log("error interceptorrrrrrrrrrrrrrrrrrrrrrrrr");
      
      console.log(error);
      

      if (error.error instanceof ErrorEvent) {
        // Client-side error
        errorMessage = `Error: ${error.error.message}`;
      } else {
        // Server-side error
        if (error.status === 401) {
          // Unauthorized - logout
          authService.logout();
          errorMessage = 'Session expired. Please login again.';
        } else if (error.status === 403) {
          errorMessage = 'You do not have permission to access this resource.';
        } else if (error.status === 404) {
          errorMessage = 'Resource not found.';
        } else if (error.error?.message) {
          errorMessage = error.error.message;
        } else {
          errorMessage = `Error Code: ${error.status}\nMessage: ${error.message}`;
        }
      }

      // Show toast notification
      toastr.error(errorMessage, 'Error');

      return throwError(() => error);
    })
  );
};