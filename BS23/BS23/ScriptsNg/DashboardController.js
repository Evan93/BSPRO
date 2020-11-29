angular.module('myFormApp', [])
    .controller('DashController', function ($scope, $http, $location, $window) {

    $scope.result = "color-default";
    $scope.isViewLoading = false;
    $scope.Posts = [];
        $scope.Comments = null;
    $scope.pagingInfo = {
        page: 1,
        itemsPerPage: 3,
   
        search: null,
        totalItems: 0
    };
  
    
    getallData();

 
    function getallData() {
        console.log($scope.pagingInfo);
        $http.get('/Dashboard/GetAllPosts?page=' + $scope.pagingInfo.page +'&&itemsperpage=' + $scope.pagingInfo.itemsPerPage)
            .then(function (data, status, headers, config) {
                //$scope.Posts = data.data;
                $scope.Posts = data.data;
               
                $scope.Count = data.data[0].totalPages;
                
                
            });
           
    };
        $scope.back = function () {
            $scope.pagingInfo.page = $scope.pagingInfo.page - 1;
            if ($scope.pagingInfo.page > 0) {

                getallData();
            }
            else {
                $scope.pagingInfo.page = 1;
                alert("You can not go more back");
            }
        };
        $scope.next = function () {

            $scope.pagingInfo.page = $scope.pagingInfo.page + 1;
            getallData();
        };
 
    $scope.getComments = function (PostId) {
        

        $http.get('/Dashboard/GetAllCommentsByPost?PostId=' + PostId)
            .then(function (data, status, headers, config) {
                $scope.Comments = data.data;
                console.log($scope.Comments);
            });
        $('#classModal').modal('show');
    };
 



})
.config(function ($locationProvider) {
    $locationProvider.html5Mode({
        enabled: true,
        requireBase: false
    });
});

