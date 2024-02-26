# EAP: Architecture Specification and Prototype

## A7: Web Resources Specification

This artifact presents an overview of the web resources implemented in the vertical prototype, organized into modules. It also includes the permissions used in the modules to establish the conditions of access to resources.

### 1. Overview


| Identifier | Module         | Description                                                                                                                                                                                                                                                                                                                                              |
| ---------- | -------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| M01        | Authentication | Web resources associated with user authentication. Includes the following system features: login, registration and logout.                                                                                                                                                                                                                               |
| M02        | Users          | Web resources associated with users. Includes the following system features: view and search users, view and edit personal profile information.                                                                                                                                                                                                                   |
| M03        | Posts          | Web resources associated with posts - questions, answers and comments. Includes the following system features: list and search questions, view recent, top, and unanswered questions. Users can post questions, answers, or comments, edit their personal questions and answers, view question details, vote on posts, and delete questions and answers. |
| M04        | Games          | Web resources associated with games. Includes the following system features: view game categories and game details, list questions related to a specific game.                                                                                                                                                                                           |
| M05        | Administration | Web resources associated with user management, specifically the system feature to ban or unban user accounts.                                                                                                                                                                                                                                            |

### 2. Permissions

This section defines the permissions used in the modules to establish the conditions of access to resources.

| Identifier | Name         | Description                                           |
|------------|--------------|-------------------------------------------------------|
| GST        | Guest        | Unauthenticated users                                 |
| USR        | User         | Authenticated users                                   |
| OWN        | Owner        | Users who are owners of the information                |
| ADM        | Administrator| System administrators                                 |


### 3. OpenAPI Specification

This section includes the complete API specification in OpenAPI (YAML) for the vertical prototype (A8).

link : https://git.fe.up.pt/lbaw/lbaw2324/lbaw23143/-/blob/main/docs/a7_openapi.yaml?plain=0 

```yaml
openapi: 3.0.0

info:
 version: '1.0'
 title: 'GameOn Web API'
 description: 'Web Resources Specification (A7) for GameOn'

servers:
- url: https://lbaw23143.lbaw.fe.up.pt/
  description: Production server

externalDocs:
 description: Find more info here.
 url: https://git.fe.up.pt/lbaw/lbaw2324/lbaw23143/-/wikis/eap
 
tags:
 - name: 'M01: Authentication'
 - name: 'M02: Users'
 - name: 'M03: Posts'
 - name: 'M04: Games'
 - name: 'M05: Administration'

paths:
 /login: 
   get:
     operationId: R101
     summary: 'R101: Login Form'
     description: 'Provide login form. Access: GST'
     tags:
       - 'M01: Authentication'
     responses:
       '200':
         description: 'Ok. Show Log-in UI'
   post:
     operationId: R102
     summary: 'R102: Login Action'
     description: 'Processes the login form submission. Access: GST'
     tags:
       - 'M01: Authentication'

     requestBody:
       required: true
       content:
         application/x-www-form-urlencoded:
           schema:
             type: object
             properties:
               email:         
                 type: string
               password:    
                 type: string
             required:
                  - email
                  - password

     responses:
       '302':
         description: 'Redirect after processing the login credentials.'
         headers:
           Location:
             schema:
               type: string
             examples:
               302Success:
                 description: 'Successful authentication. Redirect to home page.'
                 value: '/home'
               302Error:
                 description: 'Failed authentication. Redirect to login form.'
                 value: '/login'

 /logout:

   get:
     operationId: R103
     summary: 'R103: Logout Action'
     description: 'Logout the current authenticated user. Access: USR'
     tags:
       - 'M01: Authentication'
     responses:
       '302':
         description: 'Redirect after processing logout.'
         headers:
           Location:
             schema:
               type: string
             examples:
               302Success:
                 description: 'Successful logout. Redirect to home page.'
                 value: '/home'

 /register:
   get:
     operationId: R104
     summary: 'R104: Register Form'
     description: 'Provide new user registration form. Access: GST'
     tags:
       - 'M01: Authentication'
     responses:
       '200':
         description: 'Ok. Show Sign-Up UI'

   post:
     operationId: R105
     summary: 'R105: Register Action'
     description: 'Processes the new user registration form submission. Access: GST'
     tags:
       - 'M01: Authentication'

     requestBody:
       required: true
       content:
         application/x-www-form-urlencoded:
           schema:
             type: object
             properties:
               name:
                 type: string
               username:
                 type: string
               email:
                 type: string
                 format: email
               password:
                 type: string
                 format: password
               password_confirmation:
                 type: string
                 format: password
             required:
                - name
                - username
                - email
                - password
                - password_confirmation

     responses:
       '302':
         description: 'Redirect after processing the new user information.'
         headers:
           Location:
             schema:
               type: string
             examples:
               302Success:
                 description: 'Successful authentication. Redirect to home page.'
                 value: '/home'
               302Failure:
                 description: 'Failed authentication. Redirect again to register form.'
                 value: '/register'

 /home:
    get:
      operationId: R201
      summary: 'R201: View GameOn home page'
      description: 'Show GameOn home page. Access: GST, USR'
      tags:
        - 'M02: Users'
      
      responses:
       '200':
         description: 'Ok. Show home page'

 /users:
    get:
      operationId: R202
      summary: 'R202: View all users'
      description: 'Show all GameOn users. Access: GST, USR'
      tags:
        - 'M02: Users'

      responses:
        '200':
          description: 'Ok. Show users lists'
      
 /users/{id}:
    get:
      operationId: R203
      summary: 'R203: View user profile page'
      description: 'Show the individual user profile. Access: GST, USR'
      tags:
        - 'M02: Users'

      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true

      responses:
        '200':
          description: 'Ok. Show User Profile UI'

 
 /users/questions/{id}:
    get:
      operationId: R204
      summary: 'R204: View user questions'
      description: 'Show user questions page. Access: GST, USR'
      tags:
        - 'M02: Users'

      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true

      responses:
        '200':
          description: 'OK. Show the questions page for an individual user'


 /user/answers/{id}:
    get:
      operationId: R205
      summary: 'R205: View user answers'
      description: 'Show user answers page. Access: GST, USR'
      tags:
        - 'M02: Users'

      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true

      responses:
        '200':
          description: 'OK. Show the answers page for an individual user'
 

 /api/users:
    get:
      operationId: R206
      summary: 'R206: Search for users'
      description: 'Search for users with filter. Access: GST, USR'
      tags:
        - 'M02: Users'

      parameters:
        - in: query
          name: search
          description: 'Search content'
          schema:
            type: string
          required: true

        - in: query
          name: filter
          description: 'Filter users'
          schema:
            type: string
          required: true
        
        - in: query
          name: order
          description: 'Order users'
          schema:
            type: string
          required: true

      responses:
        '200':
          description: 'Success. Returns HTML code containing the list of users that match the search'

 /questions:
    get:
      operationId: R301
      summary: 'R301: View all questions'
      description: 'Show all questions. Access: GST, USR'
      tags:
        - 'M03: Posts'
      
      responses:
        '200':
          description: 'OK. Show the questions page'

    post:
      operationId: R302
      summary: 'R302: Search questions'
      description: 'Search questions. Access: GST, USR'
      tags:
        - 'M03: Posts'
      parameters:
        - name: filterCriteria
          in: query
          description: 'Filter criteria for search'
          required: false
          schema:
            type: string
        - name: searchInput
          in: query
          description: 'Input for search'
          required: false
          schema:
            type: string
        - name: orderCriteria
          in: query
          description: 'Order criteria for search'
          required: false
          schema:
            type: string
      responses:
        '200':
          description: 'OK. Search successful'

 /new-question:
      get:
        operationId: R303
        summary: 'R303: Create a new question'
        description: 'Create a new question. Access: USR'
        tags:
          - 'M03: Posts'
        responses:
          '200':
            description: 'OK. Show the new question page'

      post:
        operationId: R304
        summary: 'R304: Store a new question'
        description: 'Store a new question. Access: USR'
        tags:
          - 'M03: Posts'
        requestBody:
         required: true
         content:
           application/x-www-form-urlencoded:
             schema:
               type: object
               properties:
                 title:         
                   type: string
                 content:    
                   type: string
                 game:    
                   type: string
                 user:
                   type: integer
               required:
                    - title
                    - content
                    - game
                    - user
        responses:
          '200':
            description: 'OK. Question stored successfully'

 /questions/{id}:
    get:
      operationId: R305
      summary: 'R305: View a specific question'
      description: 'View a specific question. Access: GST, USR'
      tags:
        - 'M03: Posts'
      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true
      responses:
        '200':
          description: 'OK. Show the specific question'

 /comments/store:
    post:
      operationId: R306
      summary: 'R306: Store a comment'
      description: 'Store a comment. Access: USR'
      tags:
        - 'M03: Posts'
      requestBody:
         required: true
         content:
           application/x-www-form-urlencoded:
             schema:
               type: object
               properties:
                 content:         
                   type: string
                 user:    
                   type: integer
                 answer:    
                   type: integer
                
               required:
                    - content
                    - user
                    - answer
      responses:
        '200':
          description: 'OK. Comment stored successfully'

 /categories:
    get:
      operationId: R401
      summary: 'R401: View all game categories'
      description: 'Show all game categories. Access: GST, USR'
      tags:
        - 'M04: Games'

      responses:
        '200':
          description: 'OK. Show the game categories page'

 /categories/{id}:
    get:
      operationId: R402
      summary: 'R402: View game category page'
      description: 'Show game category page. Access: GST, USR'
      tags:
        - 'M04: Games'

      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true

      responses:
        '200':
          description: 'OK. Show the game category page'

 /game/{id}:
    get:
      operationId: R403
      summary: 'R403: View game page'
      description: 'Show game page. Access: GST, USR'
      tags:
        - 'M04: Games'

      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true

      responses:
        '200':
          description: 'OK. Show the game page'
  

 /api/users/{id}:
    post:
      operationId: R501
      summary: 'R501: Update user status'
      description: 'Update user status (ban or unban user account). Access: ADM'
      tags:
        - 'M05: Administration'
      
      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true

      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                new_status:
                  type: string
                  enum: ['Active', 'Banned']
                  description: 'The new status for the user account (active or banned).'
              required:
                - new_status
      responses:
        '200':
          description: 'Success. User status updated.'
        '401':
          description: 'Unauthorized. The action requires proper authentication and authorization.'
        '404':
          description: 'User not found.'
          
 /api/users/{id}/edit:
    post:
      operationId: R207
      summary: 'R207: Edit user profile'
      description: 'Edit user profile information. Access: OWN'
      tags:
        - 'M02: Users'
      
      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true

      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                name:
                 type: string
                username:
                 type: string
                email:
                 type: string
                 format: email
                description:
                 type: string
                
              required:
                    - name
                    - username
                    - email
                    - description
                
      responses:
        '200':
          description: 'Success. User profile updated.'
        '401':
          description: 'Unauthorized. The action requires proper authentication and authorization.'
        '404':
          description: 'User not found.'
          
  
 /api/questions:
    get:
      operationId: R307
      summary: 'R307: List Questions'
      description: 'Retrieve a list of questions. Access: GST, USR'
      tags:
        - 'M03: Posts'
      responses:
        '200':
          description: 'Success. List of questions retrieved.'
          
          
 /api/questions/{id}/delete:
    delete:
      operationId: R308
      summary: 'R308: Delete Question'
      description: 'Delete an existing question. Access: OWN'
      tags:
        - 'M03: Posts'
      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true
      responses:
        '200':
          description: 'Success. Question deleted.'
        '401':
          description: 'Unauthorized. The action requires proper authentication and authorization.'
        '404':
          description: 'Question not found.'

 /api/questions/{id}/vote:
    post:
      operationId: R309
      summary: 'R309: Vote for Question'
      description: 'Vote for a question. Access: USR'
      tags:
        - 'M03: Posts'
      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true
      responses:
        '200':
          description: 'Success. Vote registered for the question.'
        '401':
          description: 'Unauthorized. The action requires proper authentication and authorization.'
        '404':
          description: 'Question not found.'


 /api/questions/{id}/unvote:
    post:
      operationId: R310
      summary: 'R310: Unvote for Question'
      description: 'Remove vote for a question. Access: USR'
      tags: 
        - 'M03: Posts'
      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true
      responses:
        '200':
          description: 'Success. Vote removed for the question.'
        '401':
          description: 'Unauthorized. The action requires proper authentication and authorization.'
        '404':
          description: 'Question not found.'
          
 /api/questions/{id}/edit:
    put:
      operationId: R311
      summary: 'R311: Edit Question'
      description: 'Edit an existing question. Access: OWN'
      tags:
        - 'M03: Posts'
      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true
      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                user:
                 type: integer
                title:
                 type: string
                content:
                 type: string
                
              required:
                    - user
                    - title
                    - content

      responses:
        '200':
          description: 'Success. Question edited.'
        '401':
          description: 'Unauthorized. The action requires proper authentication and authorization.'
        '404':
          description: 'Question not found.'
          
        
 /api/answers:
    post:
      operationId: R312
      summary: 'R312: Store Answer'
      description: 'Store a new answer. Access: USR'
      tags:
        - 'M03: Posts'
      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                content:
                  type: string
                  description: 'The content of the answer.'
                questionId:
                  type: integer
                  description: 'The ID of the question.'
                userId:
                  type: integer
                  description: 'The ID of the user.'
      responses:
        '200':
          description: 'Success. Answer stored.'
        '401':
          description: 'Unauthorized. The action requires proper authentication and authorization.'

 /api/answers/{id}/edit:
    put:
      operationId: R313
      summary: 'R313: Edit Answer'
      description: 'Edit an existing answer. Access: OWN'
      tags:
        - 'M03: Posts'
      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true
      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                content:
                  type: string
                  description: 'The content of the answer.'
                userId:
                  type: integer
                  description: 'The ID of the user.'
      responses:
        '200':
          description: 'Success. Answer edited.'
        '401':
          description: 'Unauthorized. The action requires proper authentication and authorization.'
        '404':
          description: 'Answer not found.'

 /api/answers/{id}/delete:
    delete:
      operationId: R314
      summary: 'R314: Delete Answer'
      description: 'Delete an existing answer. Access: OWN'
      tags:
        - 'M03: Posts'
      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true
      responses:
        '200':
          description: 'Success. Answer deleted.'
        '401':
          description: 'Unauthorized. The action requires proper authentication and authorization.'
        '404':
          description: 'Answer not found.'
```

---

## A8: Vertical prototype

This artifact is about the vertical prototype of the project. It includes the implementation of the high priority user stories and also the web resources.

### 1. Implemented Features

#### 1.1. Implemented User Stories

The user stories that were implemented in the prototype are described in the following table.

| User Story reference | Name                   | Priority                   | Description                   |
| -------------------- | ---------------------- | -------------------------- | ----------------------------- |
| US01                 | See home page | High | As a User, I want to have access to a homepage, so that I can understand what the application is about. |
| US02 | View posted Q&A's | High | As a User, I want to view the questions and answers posted by other members so that I can learn from their experiences and knowledge. |
| US03 | Exact match search | High | As a User, I want an exact match search so that I can quickly find specific posts. |
| US04 | View top questions | High | As a User, I want to be able to view the top questions, so that I can have easy access to the most popular questions. |
| US05 | Browse questions | High | As a User, I want to browse questions easily so that I can discover a variety of topics related to games and expand my knowledge. |
| US06 | Full-text search | High | As a User, I want a full-text search functionality so that I can find information across all aspects of questions and answers. |
| US07 | Search filters | High | As a User, I want to use search filters based on keywords so that I can narrow down my search results and quickly find specific information about games. |
| US09 | View recent questions | High | As a User, I want to be able to view recently made questions, so that I can easily stay updated on the latest discussions. |
| US13 | Order seach results | High | As a User, I want to be able to sort the search results using different filters so that I can find what I want easily. |
| US14 | View question details | High | As a User, I want to be able to view question details, so that I can have a deeper knowledge about a question. |
| US15 | View user profiles | High | As a User, I want to view user profiles, so that I can see information about that user |
| US16 | Placeholders in Form Inputs | High | As a User, I want placeholders in form inputs so that I can clearly understand what information is expected in each field. |
| US19 | Sign-up | High | As a Guest, I want the option to create an account easily, so that I can become an active participant in the future. |
| US20 | Sign-in | High | As a Guest, I want to be able to authenticate into the system, so that I can post my own questions and answers. |
| US23 | Logout | High | As a User, I want to be able to sign out of my account. |
| US24 | View my profile | High | As a User, I want to be able to view my user profile so that I can keep it updated. |
| US25 | View my questions | High | As a User, I want to see my questions, so that I can easily track what I have been asking. |
| US26 | View my answers | High | As a User, I want to be able to view my answers, so that I can easily track my posts contribution. |
| US27 | Post questions | High | As a User, I want to post a question, so that I can seek guidance or information from the gaming community. |
| US28 | Post answers | High | As a User, I want to provide answers to questions asked by others, so that I can share my knowledge and help fellow gamers. |
| US29 | Edit question | High | As a User, I want to be able to edit my questions, so that I can correct mistakes or remove outdated information. |
| US30 | Edit answer | High | As a User, I want to be able to edit my answers so that I can revise and enhance my responses based on new information or feedback. |
| US31 | Delete question | High | As a User, I want to be able to delete questions, so that I can have control over the content I have posted. |
| US32 | Delete answer | High | As a user, I want to be able to delete answers, so that I can have control over the content I have contributed. |
| US33 | Edit profile | High | As a User, I want to change profile information, so that I can keep it updated and relevant. |
| US34 | Vote on post | High | As a User, I want to upvote or downvote questions and answers, so that I can show my appreciation or my concerns for content and contribute to its visibility on the platform. |
| US35 | Comment on post | High | As a User, I want to be able to comment on questions and answers, so that I can engage in discussions and seek clarification. |
| US53 | Block and unblock user accounts | High | As an administrator, I want to be able to block user accounts so that I can maintain a safe and respectful community environment. |


#### 1.2. Implemented Web Resources

The web resources that were implemented in the prototype are described in the next section.

<b>Module M01: Authentication</b>

| Web Resource Reference | URL                            |
| ---------------------- | ------------------------------ |
| R101: Login Form | /login |
| R102: Login Action | /login |
| R103: Logout Action | /logout |
| R104: Register Form | /register |
| R105: Register Action | /register |


<b>Module M02: Users</b>

| Web Resource Reference | URL                            |
| ---------------------- | ------------------------------ |
| R201: View GameOn Home page| /home |
| R202: View all users | /users |
| R203: View user profile page | /users/{id} |
| R204: View user questions | /users/questions/{id} |
| R205: View user answers | /users/answers/{id} |
| R206: Search for users | /api/users |
| R207: Edit user profile | /api/users/{id}/edit |

<b>Module M03: Posts</b>

| Web Resource Reference | URL                            |
| ---------------------- | ------------------------------ |
| R301: View all questions | /questions |
| R302: Search questions | /questions |
| R303: Create a new question| /new-question |
| R304: Store a new question| /new-question |
| R305: View a specific question | /questions/{id} |
| R306: Store a comment | /comments/store |
| R307: List Questions | /api/questions |
| R308: Delete Question | /api/questions/{id}/delete |
| R309: Vote for Question | /api/questions/{id}/vote |
| R310: Unvote for Question | /api/questions/{id}/unvote |
| R311: Edit Question | /api/questions/{id}/edit |
| R312: Store Answer | /api/answer |
| R313: Edit Answer | /api/answers/{id}/edit |
| R314: Delete Answer | /api/answers/{id}/delete |


<b>Module M04: Games</b>

| Web Resource Reference | URL                            |
| ---------------------- | ------------------------------ |
| R401: View all game categories | /categories |
| R402: View game category page | /categories/{id} |
| R403: View game page | /game/{id} |

<b>Module M05: Administration</b>

| Web Resource Reference | URL                            |
| ---------------------- | ------------------------------ |
| R501: Update user status | /api/users/{id} |


### 2. Prototype

The prototype is available at:  https://lbaw23143.lbaw.fe.up.pt

Credentials:
- admin user: johndoe@example.com/1234
- regular user: chloehall@email.com/1234

The code is available at: https://git.fe.up.pt/lbaw/lbaw2324/lbaw23143 

## Revision history

No changes yet.

***
GROUP23143, 23/11/2023

* Ana Azevedo, up202108654@up.pt 
* Catarina Canelas, up202103628@up.pt (Editor)
* Gabriel Ferreira, up202108722@up.pt
* Luís Du, up202105385@up.pt
